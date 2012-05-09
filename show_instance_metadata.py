#!/usr/bin/env python
"""
If run in an EC2 instance, will dump all info in the instance-data url tree.
If run outside, it probably won't find the meta-data host.
Bad things will happen if there are URL loops
"""

import sys
import urllib2
base_url='http://169.254.169.254/latest'

def main():
    init_stack=['{0}'.format(base_url)]
    while init_stack:
        try:
            url = init_stack.pop()
            c = urllib2.urlopen(url,timeout=5)
            lines = c.read().split('\n')
            print url
            for l in lines:
                print "  {0}".format(l)
                if l and l[-1] == '/':
                    l = l[0:-1]
                if l and 'http:' not in l:
                    init_stack.append('{0}/{1}'.format(url,l))
        except urllib2.HTTPError as e:
            pass
        except urllib2.URLError as e:
            sys.stderr.write('Error attempting to fetch data: {0}\n'.format(e.reason))
            exit(-1)

if __name__ == '__main__':
    main()
