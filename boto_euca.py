#!/usr/bin/env python

import logging, sys, os, yaml
from urlparse import urlparse
from boto.s3.connection import *
from boto.s3.key import Key
from boto.ec2.connection import EC2Connection
from boto.ec2.regioninfo import RegionInfo
from boto.exception import EC2ResponseError,S3ResponseError,BotoServerError

class BotoEuca(object):
    """Module for simplified boto connections (mainly for eucalyptus access)
    Assumes that the environment variables for keys are set (e.g. from .euca/eucarc).
    SYNOPSIS:
        from boto_euca import BotoEuca
        euca = BotoEuca()
        boto_s3 = euca.get_s3_connection() # standad boto.s3.S3Connection object
        #  .... do stuff on local S3
        boto_ec2 = euca.get_ec2_connection() # standard boto.ec2.EC2Connection object
        # .... do stuff on local ec2
    """
    def __init__(self,verbose=False):
        self.verbose = verbose
        self.aws_access_key = os.environ['AWS_ACCESS_KEY']
        self.aws_secret_key = os.environ['AWS_SECRET_KEY']
        self.s3_url = urlparse(os.environ['S3_URL'])
        self.ec2_url = urlparse(os.environ['EC2_URL'])
        self.s3_conn = None
        self.ec2_conn = None

    def _connect_to_s3(self):
        calling_format=SubdomainCallingFormat()
        if self.s3_url.hostname.find('amazon') == -1:  # assume that non-amazon won't use <bucket>.<hostname> format
            calling_format=OrdinaryCallingFormat()
        if (self.s3_url.scheme == 'https'):
            is_secure = True
        else:
            is_secure = False
        if self.verbose:
            debug = 2
        else:
            debug = 0
        self.s3_conn = S3Connection(
                aws_access_key_id = self.aws_access_key,
                aws_secret_access_key = self.aws_secret_key,
                is_secure = is_secure,
                port = self.s3_url.port,
                host = self.s3_url.hostname,
                path = self.s3_url.path,
                calling_format = calling_format,
                debug = debug
         )

    def get_s3_connection(self):
        if not self.s3_conn:
           self._connect_to_s3()
        return self.s3_conn

    def _connect_to_ec2(self):
        if (self.ec2_url.scheme == 'https'):
            is_secure = True
        else:
            is_secure = False
        if self.verbose:
            debug = 2
        else:
            debug = 0
        region = RegionInfo(endpoint=self.ec2_url.hostname,name=self.ec2_url.hostname)
        self.ec2_conn = EC2Connection(
                aws_access_key_id = self.aws_access_key,
                aws_secret_access_key = self.aws_secret_key,
                is_secure = is_secure,
                host = self.ec2_url.hostname,
                port = self.ec2_url.port,
                path = self.ec2_url.path,
                region = region,
                debug = debug
        )

    def get_ec2_connection(self):
        if not self.ec2_conn:
            self._connect_to_ec2()
        return self.ec2_conn

def main():
    pass

if __name__ == '__main__':
    main()
