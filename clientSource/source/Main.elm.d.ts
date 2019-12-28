export namespace Elm {
  namespace Main {
    function init(args: {
      flags: null;
    }): {
      ports: Ports;
    };
  }
}

type Ports = {
  jumpPage: SubForElmCmd<string>;
};

type SubForElmCmd<T> = {
  subscribe: (arg: (value: T) => void) => void;
};

type CmdForElmSub<T> = {
  send: (value: T) => void;
};
