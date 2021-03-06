require 'vault'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'

class Vault::Provision; end
require 'vault/provision/prototype'

require 'vault/provision/auth'
require 'vault/provision/sys'
require 'vault/provision/pki'
require 'vault/provision/secret'
require 'vault/provision/aws'

# controller for the children
class Vault::Provision
  SYSTEM_POLICIES = ['response-wrapping', 'root'].freeze

  attr_accessor :vault, :instance_dir,
                :intermediate_issuer, :pki_allow_destructive,
                :aws_update_creds

  def initialize instance_dir,
                 address: ENV['VAULT_ADDR'],
                 token: ENV['VAULT_TOKEN'],
                 aws_update_creds: false,
                 intermediate_issuer: {},
                 pki_allow_destructive: false

    @instance_dir = instance_dir
    @vault = Vault::Client.new address: address, token: token
    @aws_update_creds = aws_update_creds
    @intermediate_issuer = intermediate_issuer
    @pki_allow_destructive = pki_allow_destructive
    @handlers = [
      Sys::Audit,
      Sys::Auth,
      Auth::Ldap::Config,
      Sys::Mounts,
      Pki::Root::Generate::Internal,
      Pki::Intermediate::Generate::Internal,
      Pki::Config::Urls,
      Pki::Roles,
      Secret,
      Aws::SecretBackend,
      Sys::Policy,
      Auth::Ldap::Groups,
      Auth::Approle
    ]
  end

  def provision!
    @handlers.each do |handler|
      puts "* Calling handler #{handler}"
      handler.new(self).provision!
    end
  end

  def pki_force?
    @pki_force
  end
end
