import { acceptHMRUpdate, defineStore } from "pinia";
import { Auth, Person } from "@/api/ether.api";

export const useEtherStore = defineStore("ether", {
	state: () => {
		return {
			account: '',
			isAdmin: false,
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
        this.verifyRole();  // * 连接钱包后就立即验证权限
			} catch (error) {
        console.log(error);
      }
		},
		async verifyRole(){
			const auth = new Auth();
			this.isAdmin = await auth.verifyRole(
				"0xd980155b32cf66e6af51e0972d64b9d5efe0e6f237dfaa4bdc83f990dd79e9c8",
				this.account
			);
		}
	},
});
