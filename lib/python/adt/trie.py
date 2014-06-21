
class Trie(object):
    """TODO: docs"""
    def __init__(self, words=None):
        """TODO: docs"""
        self._root = dict()
        if words:
            load(words)
    
    def load(self, words):
        for word in words:
            self.insert(word)
    
    def contains(self, word):
        """TODO: docs"""
        node = self._root
        for letter in word:
            if letter in node:
                node = node[letter]
            else:
                return False
        else:
            return None in node
    
    def remove(self, word):
        """TODO: docs, impl"""
        pass
    
    def insert(self, word):
        """TODO: docs"""
        node = self._root
        for letter in word:
            node = node.setdefault(letter, {})
        node = node.setdefault(None, None)
    
    def __str__(self):
        """TODO: docs"""
        return str(self._root) #TODO: use different format
    
    def __repr__(self):
        """TODO: docs"""
        return str(self._root)
    
    def __getitem__(self, key):
        """TODO: docs"""
        return self._root[key]

