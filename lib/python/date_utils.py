#!/usr/bin/python

from datetime import datetime, timedelta
import calendar
import math
import re
import time

from adt.tables import StairStepAccessTable

daysPerGregorianQuadricentennialCycle = 146097
daysPerGregorianCentennialCycle = daysPerGregorianQuadricentennialCycle / 4

minutesPerDay = 1440
secondsPerDay = 86400

leap_seconds = StairStepAccessTable([
    (         0,  0),
    (  46828800,  1),
    (  78364801,  2),
    ( 109900802,  3),
    ( 173059203,  4),
    ( 252028804,  5),
    ( 315187205,  6),
    ( 346723206,  7),
    ( 393984007,  8),
    ( 425520008,  9),
    ( 457056009, 10),
    ( 504489610, 11),
    ( 551750411, 12),
    ( 599184012, 13),
    ( 820108813, 14),
    ( 914803214, 15),
    (1025136015, 16)
])

def get_gregorian(JD):
    """Return the gregorian day for the specified julian date.
    NOTE: this algorithm was taken from http://en.wikipedia.org/wiki/Julian_day
    
    To test, try these values:
    2455760 == (2011, 7, 17)
    
    """
    J = JD + 0.5 #shift the epoch back by 1/2 day to start at 00:00 instead of noon
    j = J + 32044 #shift the epoch back to astronomical year -4800 instead of
                  #the start of the Christian era in year AD 1 of the proleptic
                  #Gregorian calendar
    
    #g is the number of Gregorian quadricentennial cycles elapsed
    g = math.floor(j / daysPerGregorianQuadricentennialCycle)
    dg = math.floor(j) % daysPerGregorianQuadricentennialCycle #days since beginning of current cycle
    
    #c is the number of Gregorian centennial cycles
    c = math.floor((math.floor(dg / daysPerGregorianCentennialCycle) + 1) * 3 / 4)
    dc = dg - c * daysPerGregorianCentennialCycle
    
    b = math.floor(dc / 1461.0)
    db = math.floor(dc) % 1461
    a = math.floor((math.floor(db / 365) + 1) * 3 / 4.0)
    da = db - a * 365
    
    #integer number of full years elapsed since march 1, 4801 BC at 00:00 UTC
    y = g * 400 + c * 100 + b * 4 + a
    
    #integer number of full months elapsed since the last March 1 at 00:00 UTC
    m = math.floor((da * 5 + 308) / 153) - 2
    
    #number of days elapsed since day 1 of the month at 00:00 UTC
    d = da - math.floor((m + 4) * 153 / 5) + 122
    
    year = int(y - 4800 + math.floor((m + 2) / 12.0))
    month = int(math.floor(m + 2) % 12 + 1)
    day = int(d + 1)
    return (year, month, day)

def get_day_of_week(JDN):
    """Return the day of the week identified by the specified julian day number."""
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][int(math.floor(JDN) % 7)]

def get_julian_day_number(year, month, day):
    """Return the julian day number for the specified gregorian year, month, and day."""
    a = int(math.floor((14 - month) / 12))
    y = int(year + 4800 - a)
    m = int(month + 12 * a - 3)
    
    #note: we don't need floor() for y/{4,100,400} because y is an int (see above)
    return int(day + math.floor((153 * m + 2) / 5) + 365 * y + y / 4 - y / 100 + y / 400 - 32045)

def get_julian_date(JDN, hour, minute, second):
    """Return the julian date (JDN + seconds) for the specified date/time."""
    return JDN + (hour - 12) / 24 + minute / 1440 + second / 86400

#def get_day_of_year(year, month, day):
#    return time.strftime('%Y/%j', time.strptime('%d/%d/%d' % (year, month, day), '%Y/%m/%d'))
#
#def get_date(year, day_of_year):
#    return time.strftime('%Y/%m/%d', time.strptime('%d/%d' % (year, day_of_year), '%Y/%j'))

def to_unix_from_spm(seconds_past_midnight):
    """Convert seconds past midnight to (hour, minute, second, millisecond)."""
    millisecond = seconds_past_midnight % 1 * 1000
    spm = seconds_past_midnight // 1
    
    hour = spm // 3600
    spm -= (hour * 3600)
    
    minute = spm // 60
    spm -= (minute * 60)
    
    second = spm
    
    return (hour, minute, second, millisecond)

def to_unix(year, day, second):
    """Convert year, day of year, and second of day (seconds past midnight) to UNIX time (UTC)."""
    return to_unix_from_datetime(datetime.strptime('%d-%d' % (int(year), int(day)), '%Y-%j') + timedelta(seconds=second))

def to_unix_from_datetime(dt):
    """Convert datetime to UNIX time (UTC)."""
    return calendar.timegm(dt.timetuple()) + (dt.microsecond / 1000000.0)

def to_unix_from_gps(gps):
    """Convert GPS seconds to UNIX time (UTC)."""
    return to_unix_from_datetime(datetime(1980, 1, 6) + timedelta(seconds=(gps - leap_seconds[gps])))

def to_gps_from_unix(unix):
    """Convert UNIX time (UTC) to GPS seconds."""
    gps = (datetime.utcfromtimestamp(int(unix)) - datetime(1980, 1, 6)).total_seconds()
    return gps + leap_seconds[gps]
#    return (lambda x: x + leap_seconds[x])((datetime.utcfromtimestamp(int(unix)) - datetime(1980, 1, 6)).total_seconds())

def to_hms_from_delta(delta):
    """Convert a timedelta to HH:MM:SS (no fractional seconds)."""
    #note: this'd be a lot easier in 2.7 with str.format() and timedelta.total_seconds()
    (h, m, s, x) = to_unix_from_spm(delta.seconds)
    return '%02d:%02d:%02d' % (h + delta.days * 24, m, s)

def to_datetime_from_iso(iso8601_string):
    #TODO: this is extremely special case -- it won't handle most legal ISO-8601 strings
    return datetime(*(time.strptime(iso8601_string, '%Y-%m-%dT%H:%M:%S')[0:6]))

def to_timedelta_from_iso(iso8601_string):
    regexp = re.compile('(?P<sign>-?)P(?:(?P<years>\d+)Y)?(?:(?P<months>\d+)M)?(?:(?P<days>\d+)D)?(?:T(?:(?P<hours>\d+)H)?(?:(?P<minutes>\d+)M)?(?:(?P<seconds>\d+)S)?)?')
    duration = regexp.match(iso8601_string).groupdict(0)
    delta = timedelta(days=(int(duration['years']) * 365 + int(duration['months']) * 30 + int(duration['days'])),
            hours=int(duration['hours']), minutes=int(duration['minutes']), seconds=int(duration['seconds']))
    if duration['sign'] == '-':
        delta *= -1
    return delta

def _test():
    print 'not implemented'

if __name__ == '__main__':
    _test()

