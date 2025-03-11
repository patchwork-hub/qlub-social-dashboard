class DnsVerifier
  def self.valid_a_record?(domain, expected_ip)
    Resolv::DNS.open do |dns|
      ips = dns.getresources(domain, Resolv::DNS::Resource::IN::A).map { |res| res.address.to_s }
      ips.include?(expected_ip)
    end
  end
end
