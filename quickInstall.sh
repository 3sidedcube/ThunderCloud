# Installs Carthage dependencies.
# 
# Currently using flag "--no-use-binaries" because the binaries are not 
# yet `.xcframework`s, remove this flag when they are.
carthage update --platform ios --use-xcframeworks

# Downloads AppThinner from the ThunderCloud repository.
curl -O "https://raw.githubusercontent.com/3sidedcube/ThunderCloud/master/ThunderCloud/AppThinner"

# Makes AppThinner executable.
chmod +x AppThinner
