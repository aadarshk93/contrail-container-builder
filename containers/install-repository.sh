#!/bin/bash -e

contrail_version=${CONTRAIL_VERSION:-'4.0.2.0-35'}
os_version=${OPENSTACK_VERSION:-newton}
package_base_url=${CONTRAIL_INSTALL_PACKAGE_URL:-"https://s3-us-west-2.amazonaws.com/contrailrhel7"}

package_url=$package_base_url'/contrail-install-packages-'$contrail_version'~'$os_version'.el7.noarch.rpm'
http_status=$(curl -Isw "%{http_code}" -o /dev/null $package_url)
if [ $http_status != "200" ]; then
  echo "No Contrail packages found for Contrail version '$contrail_version' and OpenStack version '$os_version'"
  exit 1
fi

package_fname=$(mktemp)
echo Getting $package_url to $package_fname
curl -o $package_fname $package_url

package_dir=$(mktemp -d)
pushd $package_dir
rpm2cpio $package_fname | cpio -idmv
popd

echo 'Extract packages to '$repo_dir
tar -xvzf $package_dir'/opt/contrail/contrail_packages/contrail_rpms.tgz' -C $repo_dir

rm -rf $package_dir
rm $package_fname
