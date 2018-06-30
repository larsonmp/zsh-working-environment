#!/usr/bin/env python

from argparse import ArgumentParser
from collections import defaultdict
from os import getcwd
from os.path import basename, expanduser
from subprocess import PIPE, Popen
from sys import exit, stderr, stdout
from time import time
from traceback import print_exc

import logging
import logging.config
import re
import yaml


def parse_artifacts(output):
	logger = logging.getLogger('iq')
	security_section = False
	artifact_pattern = re.compile(r'.*displayName=(?P<group_id>[^ ]+)[:\s]*(?P<artifact_id>[^ ]+)[:\s]*(?P<version>[^,]+)[,].*')
	url_pattern = re.compile(r'.*(?P<url>http[^\s]*).*')
	for line in output.split('\n'):
		if 'Security' in line:
			security_section = True
		if security_section:
			match = artifact_pattern.match(line)
			if match:
				yield match.groupdict()
		if 'detailed report' in line:
			logger.info('report: %s', url_pattern.match(line).groupdict().get('url'))

def main(iq_config, debug, do_rebuild, do_dependency_insight):
	app_id = iq_config['application']['id']
	app_name = iq_config['application'].get('name')
	targets = iq_config['application']['targets']
	username = iq_config['nexus']['credentials']['username']
	password = iq_config['nexus']['credentials']['password']
	jar = expanduser(iq_config['nexus']['iq']['jar.path'])
	url = iq_config['nexus']['iq']['url']
	stage = iq_config['nexus']['iq']['stage']
	
	logger = logging.getLogger('iq')
	if do_rebuild:
		out, err = Popen(['./gradlew', '--quiet', 'clean', 'build', 'publish']).communicate()
		log_err(err)

	cmd = ['java', '-jar', jar, '-i', app_id, '-s', url, '-a', '{}:{}'.format(username, password), '-t', stage]
	if debug:
		cmd += ['-X']
	cmd += targets
	logger.debug('command: %s', cmd)
	out, err = Popen(cmd, stdout=PIPE).communicate()
	log_err(err)
	
	if do_dependency_insight:
		for artifact in parse_artifacts(out):
			logger.info('artifact: %s:%s:%s', artifact.get('group_id'), artifact.get('artifact_id'), artifact.get('version'))
			task = 'dependencyInsight'
			if app_name:
				task = app_name + ':' + task
			cmd = ['./gradlew', '--quiet', task, '--dependency', artifact.get('artifact_id'), '--configuration', 'compile']
			pipe = Popen(cmd, stdout=PIPE)
			out, err = pipe.communicate()
			log_err(err)
			for line in out.split('\n'):
				logger.debug(line)
	else:
		for line in out.split('\n'):
			logger.info(line)

def log_err(err_stream):
	if err_stream:
		logger.error('=' * 80)
		logger.error('\n' + err_stream)
		logger.error('=' * 80)

def extend(root, project):
	for key in project:
		if key in root:
			if isinstance(root[key], dict) and isinstance(project[key], dict):
				extend(root[key], project[key])
			elif root[key] == project[key]:
				pass
			else:
				root[key] = project[key] 
		else:
			root[key] = project[key]
	return root


if __name__ == '__main__':
	parser = ArgumentParser()
	parser.add_argument('-d', '--gradle-dependency-insight', action='store_true', help='analyze dependency source after running IQ')
	parser.add_argument('-r', '--gradle-rebuild', action='store_true', help='rebuild project before running IQ')
	parser.add_argument('-X', '--debug', action='store_true', help='enable debug logging in IQ')
	args = parser.parse_args()
	
	try:
		with open(expanduser('~/.nexus-iq/logging.yaml'), 'rt') as fp:
			logging_config = yaml.safe_load(fp.read())
			logging.config.dictConfig(logging_config)
	except:
		print_exc(stderr)
		logging.basicConfig(level=logging.INFO)
	
	logger = logging.getLogger('iq')
	iq_config = {}
	try:
		with open(expanduser('~/.nexus-iq/config.yaml'), 'rt') as fp:
			documents = yaml.safe_load_all(fp.read())
			iq_config = documents.next()
			logger.debug('iq_config: %s', iq_config)
			for document in documents:
				logger.debug('document: %s', document)
				if document and document.get('project') == basename(getcwd()):
					extend(iq_config, document)
	except:
		print_exc(stderr)
		exit(1)
	
	metrics_logger = logging.getLogger('metrics')
	metrics_logger.debug('execution start')
	t_start = time()
	try:
		main(iq_config, args.debug, args.gradle_rebuild, args.gradle_dependency_insight)
	except KeyboardInterrupt:
		pass
	finally:
		metrics_logger.debug('execution end')
		dt = int(time() - t_start)
		metrics_logger.info('execution duration: PT%dH%dM%dS', dt // 3600, (dt // 60) % 60, dt % 60) 

