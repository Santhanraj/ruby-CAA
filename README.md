# Ruby-CAA
A Ruby implementation of DNS - Certificate Authority Authorization (CAA) checks as per RFC 6844 Section 4 (Errata 5065, 5097)

Uses the local nameserver configuration for RR requests.

## Methods
There are two way to check CAA for a domain

`caa = CAAuth.new` <br>
`caa.domain="x.y.z"` <br>
`caa.CAA #=>returns a hash with :domain, :loc, :flag, :tag, :value`. 

or

`caa.check('x.y.z') #=>returns a hash with :domain, :loc, :flag, :tag, :value`

## Return
returns a hash containing <br>
:domain -> the primary domain <br>
:loc -> the location where the CAA RR was found. I.e., primary, CNAME, hierarchy (parent or grandparent domain), hierarchy-CNAME <br>
:flag, :tag, :value -> as per RFC 6844
