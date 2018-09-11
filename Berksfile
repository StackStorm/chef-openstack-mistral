source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'yum'
  cookbook 'apt'
  cookbook 'selinux'
  cookbook 'postgresql', '= 6.1.1'
end

cookbook 'mistral_database_test', path: 'test/fixtures/cookbooks/mistral_database_test'
cookbook 'mistral_default_test', path: 'test/fixtures/cookbooks/mistral_default_test'
