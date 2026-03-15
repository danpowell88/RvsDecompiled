import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Ravenshield Decompilation',
  tagline: 'Rebuilding Rainbow Six 3 one function at a time',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://danpowell88.github.io',
  baseUrl: '/RvsDecompiled/',

  organizationName: 'danpowell88',
  projectName: 'RvsDecompiled',

  onBrokenLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
        },
        blog: {
          showReadingTime: true,
          sortPosts: 'descending',
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          blogSidebarCount: 'ALL',
          onInlineTags: 'ignore',
          onInlineAuthors: 'ignore',
          onUntruncatedBlogPosts: 'ignore',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'RVS Decomp',
      logo: {
        alt: 'Ravenshield Decompilation',
        src: 'img/logo.svg',
      },
      items: [
        {to: '/blog', label: 'Dev Blog', position: 'left'},
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://github.com/danpowell88/RvsDecompiled',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Project',
          items: [
            {
              label: 'Dev Blog',
              to: '/blog',
            },
            {
              label: 'Docs',
              to: '/docs/intro',
            },
          ],
        },
        {
          title: 'Source',
          items: [
            {
              label: 'GitHub Repository',
              href: 'https://github.com/danpowell88/RvsDecompiled',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Ravenshield Decompilation Project. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.dracula,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['cpp', 'powershell'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
