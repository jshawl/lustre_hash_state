export const setHash = (value) => {
  if (globalThis.location) {
    globalThis.location.hash = value;
  }
};
