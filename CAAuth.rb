#!/usr/bin/ruby -Eutf-8:utf-8
# encoding: UTF-8
# Copyright 2018 Santhan Raj
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'resolv'

class CAAuth

  def initialize
  end

  def DnsRR(domain, loc)
    caa_rr = []
    Resolv::DNS.open do |dns|
      all_records = dns.getresources(domain, Resolv::DNS::Resource::IN::ANY)
      all_records.each do |rr|
        if (rr.is_a? Resolv::DNS::Resource::Generic) && (rr.class.name.split('::').last == 'Type257_Class1')
          data = rr.data.bytes
          flag = data[0].to_s
          if data[2..10].pack('c*').eql? "issuewild"
            name = data[2..10].pack('c*')
            value = data[11..-1].pack('c*')
          elsif ["issue", "iodef"].include? data[2..6].pack('c*')
            name = data[2..6].pack('c*')
            value = data[7..-1].pack('c*')
          else
            name = "<<Unknown property-name-value ->> #{data[2..-1].pack('c*')}"
            value = ''
          end
          caa_rr << {:domain => domain, :loc => loc, :flag => flag, :name => name, :value => value}
        end
      end
      dns.close()
    end
    return caa_rr
  end

  def CAA
    caa = []
    if DnsRR(@domain, '').length > 0
      caa = DnsRR(@domain, '')
    elsif CNAME(@domain) && DnsRR(CNAME(@domain), '').length > 0
      caa = DnsRR(CNAME(@domain, 'CNAME'))
    else
      check_subdomain = @domain
      while check_subdomain.to_s.split('.').length > 1
        check_subdomain = check_subdomain.to_s.split('.')[1..-1].join('.')
        if DnsRR(check_subdomain, '').length > 0
          caa = DnsRR(check_subdomain, 'parent')
        elsif CNAME(check_subdomain) && DnsRR(CNAME(check_subdomain), '').length > 0
          caa = DnsRR(CNAME(check_subdomain), 'parent-CNAME')
        end
        break if caa.length > 0
      end
      return caa
    end
  end

  def domain=(domain)
    @domain = domain
  end

  def CNAME(domain)
    Resolv::DNS.open do |dns|
      return dns.getresources(domain, Resolv::DNS::Resource::IN::CNAME)[0].name.to_s rescue nil
      dns.close()
    end
  end

  def check(domain)
    @domain = domain
    self.CAA
  end

  def CNAME?
    CNAME(@domain).nil?
  end

end
