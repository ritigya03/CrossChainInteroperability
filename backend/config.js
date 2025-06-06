require("dotenv").config();

module.exports = {
rpc: {
sepolia: process.env.SEPOLIA_RPC,
mumbai: process.env.MUMBAI_RPC,
},
contracts: {
intentsManager: "0xYourIntentsManagerAddress", // TODO: Replace this
solverRouter: "0xYourSolverRouterAddress", // TODO: Replace this
},
chainIds: {
sepolia: 11155111,
mumbai: 80001,
},
};