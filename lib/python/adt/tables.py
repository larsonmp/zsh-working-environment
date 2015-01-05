class StairStepAccessTable(object):
    """Stair-step access table. TODO: docs"""
    def __init__(self, table):
        """"""
        self._list = table
        self._current = 0
    
    def __getitem__(self, key):
        if key < 0:
            raise IndexError('index must be non-negative')
        return self._list[self._get_index(key)][1]
    
    def _get_index(self, key):
        index = -1
        while (index + 1) < len(self._list) and self._list[index + 1][0] <= key:
            index += 1
        return min(index, len(self._list) - 1)
    
    def __str__(self):
        return '; '.join(['%d: %d' % (key, value) for (key, value) in self._list])
    
    def __repr__(self):
        return '; '.join(['%d: %d' % (key, value) for (key, value) in self._list])
    
    def __iter__(self):
        return self
    
    def next(self):
        if len(self._list) <= self._current:
            self._current = 0
            raise StopIteration
        self._current += 1
        return self._list[self._current - 1]

