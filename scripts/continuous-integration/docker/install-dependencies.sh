source ./scripts/continuous-integration/docker/setup-platform-variables.sh
# Check variables correctness
if [ -z "${CPU_ARCH_DPKG}" ]; then
	echo "Missing parameter: CPU_ARCH_DPKG"
	exit 1
fi
OJDK_VERSION_NUMBER="11"
if [[ "$GH_MATRIX_SSL" == "ssl3" ]]; then
  OJDK_VERSION_NUMBER="17"
fi
install_deps() {
  apt-get install -y sudo build-essential openjdk-${OJDK_VERSION_NUMBER}-jdk locales wget cmake gperf ccache maven \
          libssl-dev ${SSL_LIB_NAME} zlib1g-dev zlib1g "crossbuild-essential-${CPU_ARCH_DPKG}"
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
      dpkg-reconfigure --frontend=noninteractive locales && \
      update-locale LANG=en_US.UTF-8
}
if [ -n "${CROSS_BUILD_DEPS_DIR}" ]; then
	CROSS_OPENJDK_PATH=""
	fix_jdk_path() {
		# Setup OpenJDK path
		CROSS_OPENJDK_PATH=$(find "$CROSS_BUILD_DEPS_DIR/usr/lib/jvm/" -maxdepth 1 -type d -iname "java*jdk*" | head -n 1)
	}

	check_jdk_existance() {
		if [[ ! -d "$CROSS_OPENJDK_PATH" ]]; then
			echo "Can't find cross OpenJDK at location $CROSS_OPENJDK_PATH"
			exit 1
		fi
	}

	PWD_BEFORE_CROSS_DEPS=$(pwd)
	if [[ ! -f "$CROSS_BUILD_DEPS_DIR/ok-013" ]]; then
		echo "Setting up cross build deps dir"
		find "$CROSS_BUILD_DEPS_DIR" -mindepth 1 -delete || true
		mkdir -p "$CROSS_BUILD_DEPS_DIR"
		cd "$CROSS_BUILD_DEPS_DIR"

		dpkg --add-architecture "${CPU_ARCH_DPKG}"
		apt-get update

		# LibZ-Dev
		apt-get download "zlib1g-dev:${CPU_ARCH_DPKG}"
		ZLIB1G_DEV_DEB=$(find . -name "zlib1g-dev_*.deb")
		dpkg -x "$ZLIB1G_DEV_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$ZLIB1G_DEV_DEB"
		# LibZ
		apt-get download "zlib1g:${CPU_ARCH_DPKG}"
		ZLIB1G_DEB=$(find . -name "zlib1g_*.deb")
		dpkg -x "$ZLIB1G_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$ZLIB1G_DEB"
		# LibSSL-Dev
		apt-get download "libssl-dev:${CPU_ARCH_DPKG}"
		LIBSSL_DEV_DEB=$(find . -name "libssl-dev_*.deb")
		dpkg -x "$LIBSSL_DEV_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$LIBSSL_DEV_DEB"
	  if [[ "$GH_MATRIX_SSL" == "ssl3" ]]; then
      # LibSSL
      apt-get download "libssl3:${CPU_ARCH_DPKG}"
      LIBSSL_DEB=$(find . -name "libssl3_*.deb")
      dpkg -x "$LIBSSL_DEB" "$CROSS_BUILD_DEPS_DIR"
		else
      # LibSSL
      apt-get download "libssl1.1:${CPU_ARCH_DPKG}"
      LIBSSL_DEB=$(find . -name "libssl1.1_*.deb")
      dpkg -x "$LIBSSL_DEB" "$CROSS_BUILD_DEPS_DIR"
		fi
		rm "$LIBSSL_DEB"
		# Java Common
		apt-get download "java-common"
		JC_DEB=$(find . -name "java-common_*.deb")
		dpkg -x "$JC_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$JC_DEB"
		# OpenJDK-JRE-Headless
		apt-get download "openjdk-${OJDK_VERSION_NUMBER}-jre-headless:${CPU_ARCH_DPKG}"
		OJDKRH_DEB=$(find . -name "openjdk-${OJDK_VERSION_NUMBER}-jre-headless_*.deb")
		dpkg -x "$OJDKRH_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKRH_DEB"
		# OpenJDK-JRE
		apt-get download "openjdk-${OJDK_VERSION_NUMBER}-jre:${CPU_ARCH_DPKG}"
		OJDKR_DEB=$(find . -name "openjdk-${OJDK_VERSION_NUMBER}-jre_*.deb")
		dpkg -x "$OJDKR_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKR_DEB"
		# OpenJDK-JDK
		apt-get download "openjdk-${OJDK_VERSION_NUMBER}-jdk-headless:${CPU_ARCH_DPKG}"
		OJDKJ_DEB=$(find . -name "openjdk-${OJDK_VERSION_NUMBER}-jdk-headless_*.deb")
		dpkg -x "$OJDKJ_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKJ_DEB"
		# OpenJDK-GUI
		apt-get download "openjdk-${OJDK_VERSION_NUMBER}-jdk:${CPU_ARCH_DPKG}"
		OJDKG_DEB=$(find . -name "openjdk-${OJDK_VERSION_NUMBER}-jdk_*.deb")
		dpkg -x "$OJDKG_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKG_DEB"

		# Fix symlinks
		find "$CROSS_BUILD_DEPS_DIR" -lname "/*" \
				-exec  sh -c "ln -sf \"\`echo \"$CROSS_BUILD_DEPS_DIR\$(readlink \$0)\"\`\" \"\$0\"" {} \;

		echo "Cross build deps dir setup finished, testing..."

		# Check if openjdk is found
		fix_jdk_path
		check_jdk_existance

		touch "$CROSS_BUILD_DEPS_DIR/ok-013"
	else
	  apt-get update
	fi
	install_deps
	echo "Cross build deps dir setup done"
	fix_jdk_path
	check_jdk_existance
	cd "${PWD_BEFORE_CROSS_DEPS}"
else
  apt-get update
  install_deps
fi