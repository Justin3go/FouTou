import { ethers } from "ethers";
import { acceptHMRUpdate, defineStore } from "pinia";
import contractABI from "../../../contracts/artifacts/FouTou.json";
const contractAddress = "0x13965A9843393d7a4bb2a4b28a83271e6f97BF99";

export const useEtherStore = defineStore("ether", {
	state: () => {
		return {
			account: '',
		};
	},
	actions: {
		async connectWallet() {
			try {
				const { ethereum } = window;
				if (!ethereum) {
					alert("Must connect to MetaMask!");
					return;
				}
				const myAccounts = await ethereum.request({
					method: "eth_requestAccounts",
				});

        console.log("connected: ", myAccounts[0]);
        this.account= myAccounts[0];
        
			} catch (error) {
        console.log(error);
      }
		},
	},
});
