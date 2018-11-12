#
# cookbook::oracle_client_fx
# resource::patchelf_fx
#
# author::fxinnovation
# description::Run patchelf to a set of binaries
#
resource_name :patchelf_fx

provides :patchelf_fx, os: 'linux'

property :library_path, String
property :binary_path,  String

action :set_rpath do
  package 'patchelf' do
    action :nothing
    # Only remove patchelf if it wasn’t installed before
    subscribes :remove, 'package[patchelf]', :delayed
  end

  # There is no guard yet, because it would need to test every linked library for every binary.
  execute 'makes sure oracle binaries get its libraries' do
    command "find #{new_resource.binary_path} -type f -exec file {} \\; | grep ELF | cut -d ':' -f 1 | while read binary; do patchelf --set-rpath #{new_resource.library_path} $binary; done"
    notifies :install, 'package[patchelf]', :before
  end
end
