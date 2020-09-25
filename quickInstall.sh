# Installs Carthage dependencies.
./carthage-build.sh bootstrap --platform ios

# Downloads AppThinner from the ThunderCloud repository.
curl -O "https://raw.githubusercontent.com/3sidedcube/ThunderCloud/master/ThunderCloud/AppThinner"

# Makes AppThinner executable.
chmod +x AppThinner
