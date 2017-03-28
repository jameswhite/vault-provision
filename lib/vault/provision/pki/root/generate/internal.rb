# create the CA
class Vault::Provision::Pki::Root::Generate::Internal < Vault::Provision::Prototype
  include Vault::Provision::Pki

  def gen_file mount_point
    "#{@instance_dir}/#{mount_point}/root/generate/internal.json"
  end

  def repo_files
    mounts = @vault.sys.mounts
    generators = mounts.keys.select do |mp|
      mounts[mp].type == 'pki' && FileTest.file?(gen_file(mp))
    end
    generators.map { |mp| gen_file(mp) }
  end

  def provision!
    repo_files.each do |rf|
      mount_point = rf.split('/')[-4]
      next if generated? mount_point
      resp = @vault.post "v1/#{mount_point}/root/generate/internal", File.read(rf)
      next unless @intermediate_issuer.empty?
    end
  end
end
