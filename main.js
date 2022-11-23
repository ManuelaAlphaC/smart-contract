const { Alchemy, Network } = require("alchemy-sdk");

const config = {
    apiKey: "Lbs0QETGJZRZKTXaxtf8dXUeo0TcRaQx",
    network: Network.MATIC_MAINNET,
};
const alchemy = new Alchemy(config);

const main = async () => {

    // The pond contract address
    const address = "0x4Fe694B2C5F6aBDE8B66876EfB11FB3efCC8615f";

    // Block number or height
    const block = "35657012";

    // Get owners 
    const owners = await alchemy.nft.getOwnersForContract(address, false, block);
    console.log(owners);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();

// Nel terminale digita node main.js
