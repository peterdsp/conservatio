/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",
  // emit app/index.html so GitHub Pages resolves /app without relying on
  // extensionless fallbacks
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
}

module.exports = nextConfig
