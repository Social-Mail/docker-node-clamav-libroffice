# docker-node-clamav-libroffice
This is a simple Docker Container that combines node-alpine with clamav

clamD and freshClamD are not started automatically. This is useful when you want to use node-clamd module.

# How to use

1. Use this as a base image for your node-alpine containers.
2. In your start script, you can use following to start clamD and freshClam in node's own process tree.

```javascript

/**
 * @type { ((ms: number, signal: Abortsignal) => Promise) }
 */
const sleep = (ms,signal) => {
    if (signal?.aborted) {
        return 1;
    }
    return new Promise((resolve, reject) => {
        const id = setTimeout(resolve, ms);
        if (signal) {
            signal.onabort = () => {
                clearTimeout(id);
                resolve();
            };
        }
    });
}

/**
 * @type { ((ms: number, signal: Abortsignal) => Promise) }
 */
const spawnPromise = (path, args) => new Promise((resolve, reject) => {
    const cd = spawn(path, args);
    cd.stdout.on("data", (data) => {
        console.log(`${path}: ${data}`);
    });
    cd.stderr.on("data", (data) => {
        console.error(`${path}: ${data}`);
    });
    cd.on("close", resolve);
});

/**
 * @type { ((everySeconds: number, path: string, args: string[]) => void) }
 */
const spawnLoop = (everySeconds, path, args) => {
    const run = async () => {
        const everyMS = everySeconds * 1000;
        while (true) {
            await spawnPromise(path, args);
            console.log(`${path} closed, restarting in ${everySeconds} seconds`);
            await sleep(everyMS);
        }
    };
    run().catch(console.error);
};

const runClamD = () => {
    // In case if clamd fails
    // this will restart clamd every 15 seconds
    spawnLoop(15, "clamd");

    // This will start freshclam once every 24 hours
    spawnLoop(60 * 60 * 24, "freshclam");
};


// You must call this somewhere in your start of script
runClamD();

```

# Updates

Updated Daily.
