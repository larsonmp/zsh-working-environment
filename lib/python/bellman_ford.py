#!/usr/bin/env python

import sys

class Graph():
    def __init__(self, vertex_list, edge_dict):
        self._vertices = vertex_list
        self._edges = edge_dict
    
    @property
    def vertex_list(self):
        return self._vertices
    
    @property
    def edge_dict(self):
        return self._edges


class BellmanFord(object):
    def __init__(self, graph):
        self.distances = {}
        self.parents = {}
        self.graph = graph
    
    def crunch(self, start):
        for vertex in self.graph.vertex_list:
            if self.graph.edge_dict.has_key((start, vertex)):
                self.distances[vertex] = sys.maxint
        self.distances[start] = 0
        self.parents[start] = None
        
        for i in xrange(len(self.graph.vertex_list) - 1):
            for edge in self.graph.edge_dict.keys():
                if (self.graph.edge_dict[edge] + self.distances[edge[0]]) < self.distances[edge[1]]:
                    self.distances[edge[1]] = self.graph.edge_dict[edge] + self.distances[edge[0]]
                    self.parents[edge[1]] = edge[0]
        
        #one final check for negative weight cycles.
        
        for edge in self.graph.edge_dict.keys():
            if (self.graph.edge_dict[edge] + self.distances[edge[0]]) < self.distances[edge[1]]:
                self.distances[edge[1]] = self.graph.edge_dict[edge] + self.distances[edge[0]]
                self.parents[edge[1]] = edge[0]
                return edge[1] #return here since, a negative weight cycle is detected
        
        return None #return none on successful completion.

