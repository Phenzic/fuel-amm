/* Autogenerated file. Do not edit manually. */

/* tslint:disable */
/* eslint-disable */

/*
  Fuels version: 0.82.0
  Forc version: 0.49.3
  Fuel-Core version: 0.22.1
*/

/**
 * Mimics Sway Enum.
 * Requires one and only one Key-Value pair and raises error if more are provided.
 */
export type Enum<T> = {
  [K in keyof T]: Pick<T, K> & { [P in Exclude<keyof T, K>]?: never };
}[keyof T];

/**
 * Mimics Sway Option and Vectors.
 * Vectors are treated like arrays in Typescript.
 */
export type Option<T> = T | undefined;

export type Vec<T> = T[];