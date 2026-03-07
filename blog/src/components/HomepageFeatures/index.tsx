import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  icon: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Binary Reconstruction',
    icon: '🔬',
    description: (
      <>
        Rebuilding 15 DLLs and 1 EXE from machine code back to compilable C++,
        verified byte-by-byte against the original 2003 retail binaries.
      </>
    ),
  },
  {
    title: 'Matching Toolchain',
    icon: '🛠️',
    description: (
      <>
        Using the original MSVC 7.1 compiler, DirectX 8 SDK, and Windows 2003
        Platform SDK — the exact toolchain Ubisoft used to ship the game.
      </>
    ),
  },
  {
    title: 'Open Knowledge',
    icon: '📡',
    description: (
      <>
        Every technique, script, and lesson learned is documented in the dev blog.
        Follow along as we reverse-engineer a classic tactical shooter.
      </>
    ),
  },
];

function Feature({title, icon, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center" style={{fontSize: '3rem', marginBottom: '0.5rem'}}>
        {icon}
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={clsx(styles.features, 'features-section')}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
