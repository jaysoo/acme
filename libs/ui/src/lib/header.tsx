import React from 'react';

import styles from './header.module.css';

export interface HeaderProps {
  children: React.ReactNode;
}

export function Header(props: HeaderProps) {
  return <h1 className={styles.header}>{props.children}</h1>;
}

export default Header;
