require 'spec_helper'

describe Vault::Provision do
  it "has a cubbyhole" do
    expect(client.sys.mounts[:cubbyhole].description).to \
      include 'per-token private secret storage'
  end

  it "has an ldap auth" do
    expect(client.sys.auths[:ldap].type).to be == 'ldap'
  end

  it "has a token auth" do
    expect(client.sys.auths[:token].type).to be == 'token'
  end

  it "has an ldap config" do
    client.get('auth/ldap/config').to be
  end

  #it "has a pki-root mount" do
  #  expect(client.sys.mounts).to include 'pki-root'
  #end
end
