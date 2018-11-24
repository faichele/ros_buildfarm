RUN mkdir /tmp/keys
@{
debian_before_stretch = ('squeeze', 'wheezy', 'jessie')
ubuntu_before_bionic = (
    'precise', 'quantal', 'raring', 'saucy',
    'trusty', 'utopic', 'vivid', 'wily',
    'xenial', 'yakkety', 'zesty', 'artful')
}@
@[if os_name == 'debian' and os_code_name not in debian_before_stretch or os_name == 'ubuntu' and os_code_name not in ubuntu_before_bionic]@
@# In Debian Stretch apt doesn't depend on gnupg anymore
@# https://anonscm.debian.org/cgit/apt/apt.git/commit/?id=87d468fe355c87325c943c40043a0bb236b2407f
RUN for i in 1 2 3; do apt-get update && apt-get install -q -y gnupg && apt-get clean && break || if [[ $i < 3 ]]; then sleep 5; else false; fi; done
@[end if]@
@[for i, key in enumerate(distribution_repository_keys)]@
RUN echo "@('\\n'.join(key.splitlines()))" > /tmp/keys/@(i).key && apt-key add /tmp/keys/@(i).key
@[end for]@
@{
if "deb http://packages.ros.org/ros/ubuntu xenial main" not in distribution_repository_urls:
    distribution_repository_urls.append("deb http://packages.ros.org/ros/ubuntu xenial main")
    distribution_repository_keys.append("-----BEGIN PGP PUBLIC KEY BLOCK-----

mQGiBEsy5KkRBADJbDSISoamRM5AA20bfAeBuhhaI+VaiCVcxw90sq9AI5lIc42F
WzM2acm8yplqWiehAqOLKd+iIrqNGZ+VavZEPTx7o06UZUMRoPBiTFaCwrQ5avKz
lt7ij8PRMVWNrJ7A2lDYXfFQVV1o3Xo06qVnv0KLLUmiur0LBu4H/oTH3wCgt+/I
D3LUKaMJsc77KwFBTjHB0EsD/26Z2Ud12f3urSNyN6VMWnP3rz6xsmtY4Qsmkbnr
JuduxCQBZv6bX1Cr2ulXkv0fFOr+s5OyUv7zyCPbxiJFh3Br7fJGb0b5/M208KPe
giITY9hMh/aUbKjXCPoOXPxSL6SWOWV8taR6903EFyLBN0qno/kXIBKnVqBZobgn
jIEPA/0fTnxtZtE7EpirGQMF2caJfv7/LCgXmRs9xAhgbE0/caoa1tnc79uaHmLZ
FtbGFoAO31YNYM/IUHtmabbGdvZ4oYUwDhjBevVvC7aI+XhuNGK5mU8qCLLSEUOl
CUr6BJq/0iFmjwjmwk9idZEYhqSNy2OoYJbq45rbHfbdKLEVrbQeUk9TIEJ1aWxk
ZXIgPHJvc2J1aWxkQHJvcy5vcmc+iGAEExECACAFAksy5KkCGwMGCwkIBwMCBBUC
CAMEFgIDAQIeAQIXgAAKCRBVI7rusB+hFmk7AJ0XsLp05KA8l3YzAumZfjSN04MZ
jQCfQHfp4aQUXdOCUtetVo0QZUX3IuO5Ag0ESzLkrhAIAOCuSC83VXYWf8gOMSzd
xwpsH/uLV9Wze2LGnajsJLjEOhcsz2BHfxqNXhYaE9aQaodPCpbUAkPq8tLbpXy0
SWRCx0F5RcplXx5vIWbP6TlfPbRpK70w7IWd6vsNrjwEHjlhOLcNcj42sp5pgx4b
dceK06k5Ml2hYovPnD9o2TYgjOqg5FHZ2g1J0103n/66bN/hZnpLaZJYQiPWCyq6
K0565i1k2Y7hgWB/OXqwaqCehqmLTvpyQGzE1UJvKLuYU+T+4hBnSPbT3KIi5fCz
lIwvxijOMcfbkLhzYQXcU0Rd1VItcd5nmPL4z97jBxzuhkgxXpGR4WGKhvsA2Z9Y
UtsAAwYH/3Bf44bTpD9bVADUdab3e7zm8iHfh9K/a83mIgDB7mHV6WuemQVTf/1d
eu4mI5WtpbOCoucybGfjGIIAcSxwIx6VfC7HSp4J51bOpHhbdDffUEk6QVsZjwoF
yn3W9W3ZVeTI+ch/Qoo5a98SnmdjN8eXI/qCuiXOHc6rXDXc2R0iox/1EAS8xGVd
cYZe7IWBO2CjCknyhLrWxZHoy+i1GCZ9KvPF/Ef2dmLhCydT73ZlumsY8N5vm76Q
ul1G7f8LNbnMgXQafRkPffrAXSVhGY3Z2IiBwFNgxcKTq479l7yedYRGeU1A+SYI
YmRFWHXt3rTkMlQSpxCsB0fAYfrwEqqISQQYEQIACQUCSzLkrgIbDAAKCRBVI7ru
sB+hFpryAJ9qNz3h3ijt9TkAV0CHufsPT6Cl4gCglfg7tJn2lsSF3HTpoDDO1Fgg
x9o=
=AGYp
-----END PGP PUBLIC KEY BLOCK-----")
}@
@[for url in distribution_repository_urls]@
RUN echo deb @url @os_code_name main | tee -a /etc/apt/sources.list.d/buildfarm.list
@[if add_source and url == target_repository]@
RUN echo deb-src @url @os_code_name main | tee -a /etc/apt/sources.list.d/buildfarm.list
@[end if]@
@[end for]@
@# On Ubuntu Trusty a newer version of dpkg is required to install Debian packages created by stdeb on newer distros
@[if os_name == 'ubuntu' and os_code_name == 'trusty']@
RUN for i in 1 2 3; do apt-get update && apt-get install -q -y dpkg && apt-get clean && break || if [[ $i < 3 ]]; then sleep 5; else false; fi; done
@[end if]@
