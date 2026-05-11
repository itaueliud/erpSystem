import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');

  // CDN base URL for static assets in production (Req 37.6)
  const cdnBaseRaw = (env.VITE_CDN_BASE_URL ?? '').trim();

  const resolveBase = (): string => {
    if (mode !== 'production') return '/';
    if (!cdnBaseRaw) return '/';

    const lowered = cdnBaseRaw.toLowerCase();
    if (lowered === 'undefined' || lowered === 'null') return '/';

    // Accept absolute HTTP(S) URLs and root-relative paths only.
    if (cdnBaseRaw.startsWith('/')) return cdnBaseRaw.endsWith('/') ? cdnBaseRaw : `${cdnBaseRaw}/`;
    try {
      const parsed = new URL(cdnBaseRaw);
      if (parsed.protocol === 'http:' || parsed.protocol === 'https:') {
        return cdnBaseRaw.endsWith('/') ? cdnBaseRaw : `${cdnBaseRaw}/`;
      }
    } catch {
      return '/';
    }

    return '/';
  };

  return {
    // Use CDN base in production only when it is valid; otherwise stay same-origin.
    base: resolveBase(),

    plugins: [react()],

    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@shared': path.resolve(__dirname, './src/shared'),
        '@portals': path.resolve(__dirname, './src/portals'),
        'use-sync-external-store/shim/index.js': path.resolve(__dirname, './src/__mocks__/use-sync-external-store/shim/index.js'),
        'use-sync-external-store/shim': path.resolve(__dirname, './src/__mocks__/use-sync-external-store/shim/index.js'),
        'use-sync-external-store': path.resolve(__dirname, './src/__mocks__/use-sync-external-store/index.ts'),
      },
    },

    build: {
      // Minify with esbuild (default) — fast and produces small output (Req 37.4)
      minify: 'esbuild',

      // Enable CSS code splitting so each chunk only loads the CSS it needs
      cssCodeSplit: true,

      // Raise the chunk-size warning threshold slightly (portals can be large)
      chunkSizeWarningLimit: 600,

      rollupOptions: {
        output: {
          // Manual chunk splitting — each portal becomes its own async chunk
          // so the initial bundle stays small (Req 37.3, 37.4)
          manualChunks(id) {
            if (id.includes('/portals/ceo')) return 'portal-ceo';
            if (id.includes('/portals/executive')) return 'portal-executive';
            if (id.includes('/portals/clevel')) return 'portal-clevel';
            if (id.includes('/portals/operations')) return 'portal-operations';
            if (id.includes('/portals/technology')) return 'portal-technology';
            if (id.includes('/portals/agents')) return 'portal-agents';
            if (id.includes('/portals/trainers')) return 'portal-trainers';

            // Vendor chunk — large third-party libs that change infrequently
            if (id.includes('node_modules')) {
              if (id.includes('react') || id.includes('react-dom') || id.includes('react-router')) {
                return 'vendor-react';
              }
              if (id.includes('chart.js') || id.includes('react-chartjs')) {
                return 'vendor-charts';
              }
              if (id.includes('@reduxjs') || id.includes('react-redux') || id.includes('redux')) {
                return 'vendor-redux';
              }
              if (id.includes('@tanstack')) {
                return 'vendor-query';
              }
              return 'vendor';
            }
          },
        },
      },
    },

    server: {
      port: 5173,
      proxy: {
        '/api': {
          target: 'http://localhost:3000',
          changeOrigin: true,
        },
      },
    },

    test: {
      globals: true,
      environment: 'jsdom',
      setupFiles: ['./src/test-setup.ts'],
      css: false,
    },
  };
});
