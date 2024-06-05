export const setHash = (value) => {
  if (globalThis.location) {
    globalThis.location.hash = value;
  }
};

export const getHash = () => globalThis.location?.hash ?? "";

export const listen = (dispatch) => {
  dispatch(getHash());
  return globalThis.addEventListener("hashchange", () => {
    return dispatch(getHash());
  });
};
