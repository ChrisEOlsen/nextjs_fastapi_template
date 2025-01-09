const path = require('path');

module.exports = {
  webpack: (config) => {
    // Add alias for the src folder
    config.resolve.alias['@'] = path.resolve(__dirname, 'src');
    return config;
  },
};
