require 'spec_helper'

describe Vault::Provision do
  it "has a cubbyhole" do
    expect(client.sys.mounts[:cubbyhole].description).to \
      include 'per-token private secret storage'
  end

  it "has an ldap auth" do
    expect(client.sys.auths[:ldap].type).to be == 'ldap'
  end

  it "has an ldap admin group" do
    resp = client.get('v1/auth/ldap/groups/admin')
    expect(resp[:data]).to be
    expect(resp[:data][:policies].split(',')).to include 'security_admin'
  end

  it "has an ldap operators group" do
    resp = client.get('v1/auth/ldap/groups/operators')
    expect(resp[:data]).to be
    expect(resp[:data][:policies]).to include 'master_of_secrets'
  end

  it "has a token auth" do
    expect(client.sys.auths[:token].type).to be == 'token'
  end

  it "has an ldap config" do
    config_data = client.get('v1/auth/ldap/config')[:data]
    expect(config_data[:url]).to be == 'ldaps://ldap.example.com'
  end

  it "has a pki-root mount" do
    expect(client.sys.mounts.keys).to include :'pki-root'
  end

  it "has a CA" do
    expect(client.get('v1/pki-root/ca/pem')).to include "BEGIN CERTIFICATE"
  end

  it "has pki-root config urls" do
    expect(client.get('v1/pki-root/config/urls')[:data][:crl_distribution_points].to_s).to include 'https://cdn.example.com'
  end

  it "has pki-intermediate config urls" do
    expect(client.get('v1/pki-intermediate/config/urls')[:data][:issuing_certificates].to_s).to include 'https://cdn.example.com'
  end

  it "has pki-intermediate ca" do
    expect(client.get('v1/pki-intermediate/ca/pem')).to include "BEGIN CERTIFICATE"
  end

  it "has a dvcert role for intermediate" do
    expect(client.get('v1/pki-intermediate/roles/dvcert')[:data][:allowed_domains]).to include "vault.example.com"
    expect(client.get('v1/pki-intermediate/roles/dvcert')[:data][:allow_any_name]).to be_falsey
  end

  it "has an unlimited role for root" do
    expect(client.get('v1/pki-root/roles/unlimited')[:data][:allow_any_name]).to be_truthy
  end

  it "has a master_of_secrets policy" do
    expect(client.sys.policy('master_of_secrets').rules).to include '"sys/auth/*"'
    expect(client.sys.policy('master_of_secrets').rules).to include '"secret/*"'
  end

  it "has a secret squirrel" do
    expect(client.sys.mounts[:squirrel].type).to be == 'generic'
  end

  it "has an approle mount" do
    expect(client.sys.auths[:approle].type).to be == 'approle'
  end

  it "has approle role for frontends" do
    resp = client.get('v1/auth/approle/role/frontends')
    expect(resp[:data]).to be
    expect(resp[:data][:secret_id_num_uses]).to be == 255
  end

  it "has an approle mount named bob" do
    expect(client.sys.auths[:bob_the_dancing_approle_mount].type).to be == 'approle'
  end

  it "bob has dreams too ya know" do
    resp = client.get('v1/auth/bob_the_dancing_approle_mount/role/dream')
    expect(resp[:data]).to be
    expect(resp[:data][:bound_cidr_list]).to be == '10.0.1.0/24'
  end

  it "in death, a member of project mayhem has a name (or at least a role-id)" do
    resp = client.get('v1/auth/bob_the_dancing_approle_mount/role/death/role-id')
    expect(resp[:data]).to be
    expect(resp[:data][:role_id]).to be == 'robert_paulson'
  end

  it "can provision generic k/v pairs" do
    good = client.get('v1/secret/foo/good')
    expect(good[:data]).to be
    expect(good[:data][:whiskers]).to be == 'on kittens'

    bad = client.get('v1/secret/bar/bad')
    expect(bad[:data][:'😡']).to be \
      == 'How I feel when people put secrets in source code.'
    expect(bad[:data][:'😀']).to be \
      == 'How I feel when people put non-secret config data in k/v stores with decent access control policies'

    yummy = client.get('v1/secret/baz/yummy')

    expect(yummy[:data]).to be
    expect(yummy[:data][:bear]).to be == '🐻  rawr!'
  end
end
