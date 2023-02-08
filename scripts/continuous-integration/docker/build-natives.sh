#!/bin/bash -e
export JAVA_HOME
JAVA_HOME="$(find "/usr/lib/jvm/" -maxdepth 1 -type d -iname "java*jdk*" | head -n 1)/"
export JAVA_INCLUDE_PATH="$JAVA_HOME/include"
source ./scripts/continuous-integration/github-workflows/setup-variables.sh
export CROSS_BUILD_DEPS_DIR="$PWD/cross-build-deps"
# Check variables correctness
if [ -z "${CPU_ARCH_DPKG}" ]; then
	echo "Missing parameter: CPU_ARCH_DPKG"
	exit 1
fi
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
		rm -rf "$CROSS_BUILD_DEPS_DIR" || true
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
      apt-get download "libssl:${CPU_ARCH_DPKG}"
      LIBSSL_DEB=$(find . -name "libssl_*.deb")
      dpkg -x "$LIBSSL_DEB" "$CROSS_BUILD_DEPS_DIR"
		fi
		rm "$LIBSSL_DEB"
		# Java Common
		apt-get download "java-common"
		JC_DEB=$(find . -name "java-common_*.deb")
		dpkg -x "$JC_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$JC_DEB"
		# OpenJDK-JRE-Headless
		apt-get download "openjdk-11-jre-headless:${CPU_ARCH_DPKG}"
		OJDKRH_DEB=$(find . -name "openjdk-11-jre-headless_*.deb")
		dpkg -x "$OJDKRH_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKRH_DEB"
		# OpenJDK-JRE
		apt-get download "openjdk-11-jre:${CPU_ARCH_DPKG}"
		OJDKR_DEB=$(find . -name "openjdk-11-jre_*.deb")
		dpkg -x "$OJDKR_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKR_DEB"
		# OpenJDK-JDK
		apt-get download "openjdk-11-jdk-headless:${CPU_ARCH_DPKG}"
		OJDKJ_DEB=$(find . -name "openjdk-11-jdk-headless_*.deb")
		dpkg -x "$OJDKJ_DEB" "$CROSS_BUILD_DEPS_DIR"
		rm "$OJDKJ_DEB"
		# OpenJDK-GUI
		apt-get download "openjdk-11-jdk:${CPU_ARCH_DPKG}"
		OJDKG_DEB=$(find . -name "openjdk-11-jdk_*.deb")
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
	fi
	echo "Cross build deps dir setup done"
	fix_jdk_path
	check_jdk_existance
	cd "${PWD_BEFORE_CROSS_DEPS}"
	apt install -y "crossbuild-essential-${CPU_ARCH_DPKG}"
fi

cd scripts/core
source ./setup-variables.sh
./install-dependencies.sh
./generate_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
./compile_td.sh
./compile_tdjni.sh
./build_generated_maven_project.sh
