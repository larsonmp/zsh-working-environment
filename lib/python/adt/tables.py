
class StairStepAccessTable(object):
    """Stair-step access table. TODO: docs"""
    def __init__(self, table):
        """"""
        self._table = table
    
    def __getitem__(self, key):
        if key < 0:
            raise IndexError('index must be non-negative')
        return self._table[self._get_index(key)][1]
    
    def _get_index(self, key):
        index = -1
        while (index + 1) < len(self._table) and self._table[index + 1][0] <= key:
            index += 1
        return min(index, len(self._table) - 1)
    
    def __str__(self):
        return '; '.join(['%d: %d' % (key, value) for (key, value) in self._table])
    
    def __repr__(self):
        return '; '.join(['%d: %d' % (key, value) for (key, value) in self._table])
