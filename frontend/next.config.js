const path = require('path');

module.exports = {
  webpack: (config) => {
    config.resolve.alias['@'] = path.resolve(__dirname, 'src');
    return config;
  },
  async rewrites() {
    return [
      {
        source: "/api/:path*", // Proxy all requests starting with `/api/`
        destination: "http://localhost:8000/:path*", // Forward to FastAPI backend running on port 8000
      },
    ];
  },
};
