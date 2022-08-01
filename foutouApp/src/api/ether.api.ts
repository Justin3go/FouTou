import axios from "axios";
import { ethers, EventFilter } from "ethers";
import contractABI from "../../../contracts/artifacts/FouTou.json";
// import { useEtherStore } from "@/store/etherStore"; 非vue组件不能使用pinia

const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS;

// 数组代表可选：https://docs.ethers.io/v5/concepts/events/#events--filters
type TopicAccount = string | null | Array<any>;
type TopicBool = boolean | null | Array<any>;
type TopicInt = number | null | Array<any>;

function initContract() {
	const { ethereum } = window;
	if (ethereum) {
		const provider = new ethers.providers.Web3Provider(ethereum);
		const signer = provider.getSigner();
		const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI.abi, signer);
		return { provider, signer, contract };
	} else {
		throw "Ethereum object doesn't exist!";
	}
}

// * 因为有些api获取的数据还需要前端进行封装处理
export class BaseAuth {
	constructor() {
		const { contract } = initContract();
		this.contract = contract;
	}
	contract;
	// 1. var
	/** 验证某个账户是否属于某个角色(SUPER_ADMIN, ADMIN, USER)
	 * @param role bytes32 哈希了的role字符，以下三选一
	 * SUPER_ADMIN=>0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
	 * ADMIN=>0xd980155b32cf66e6af51e0972d64b9d5efe0e6f237dfaa4bdc83f990dd79e9c8
	 * USER=>0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
	 * @param account address
	 */
	verifyRole(role: string, account: string): Promise<boolean> {
		return this.contract.roles(role, account);
	}
	getWITHDRAW_OWNER(): Promise<string>{
		return this.contract.WITHDRAW_OWNER();
	}
	/** 获取预计管理员的数量 */
	getADMIN_NUM(): Promise<number> {
		return this.contract.ADMIN_NUM();
	}
	getREQUIRED_ADMIN(): Promise<number> {
		return this.contract.REQUIRED_ADMIN();
	}
	getREQUIRED_REPORTER(): Promise<number> {
		return this.contract.REQUIRED_REPORTER();
	}
	getREPORT_ETHER():Promise<number>{
		return this.contract.REPORT_ETHER();
	}
	getREPORT_FEEDBACK():Promise<number>{
		return this.contract.REPORT_FEEDBACK();
	}
	getREQUIRED_FANS(): Promise<number> {
		return this.contract.REQUIRED_FANS();
	}
	getIS_TEST_VERSION(): Promise<boolean> {
		return this.contract.IS_TEST_VERSION();
	}
	// 2. function
	// setConfig(){},
	// transferSUPER_ADMIN(){},
	/**
	 * @param account address
	 */
	USER2ADMIN(account: string): Promise<void> {
		return this.contract.USER2ADMIN(account);
	}
	/**
	 * @param account address
	 */
	ADMIN2USER(account: string): Promise<void> {
		return this.contract.ADMIN2USER(account);
	}
	/** 只有管理员有权限的注册函数
	 * @param account address
	 */
	registerByAdmin(account: string): Promise<void> {
		return this.contract.registerByAdmin(account);
	}
	/** 只有正式版本中才能使用的函数
	 * @param account address
	 */
	publicRegister(account: string): Promise<void> {
		return this.contract.publicRegister(account);
	}
	getBalance():Promise<number>{
		return this.contract.getBalance();
	}
	// withdraw(){}
	// 3. event
	// 事件相关，参数名字虽然与合约事件参数名相同，但这里代表的是该参数的topic集合，并且有indexed的这里才有参数
	E_transferAdmin(account: TopicAccount = null, grantOrRevoke: TopicBool = null) {
		const eventFilter = this.contract.filters.TransferAdmin(account, grantOrRevoke);
		return this.contract.queryFilter(eventFilter);
	}
	E_transferSUPER_ADMIN(oldAccount: TopicAccount = null, newAccount: TopicAccount = null) {
		const eventFilter = this.contract.filters.TransferSUPER_ADMIN(oldAccount, newAccount);
		return this.contract.queryFilter(eventFilter);
	}
	E_register(admin: TopicAccount = null, account: TopicAccount = null) {
		const eventFilter = this.contract.filters.Register(admin, account);
		return this.contract.queryFilter(eventFilter);
	}
	// E_withdraw(){}
}

export class BasePhoto {
	constructor(){
		const { contract } = initContract();
		this.contract = contract;
	}
	contract;
	// 1. var
	/** 根据tokenID查询FT所有信息
	 * @param tokenID uint256
	 * @return json  // todo
	 */
	getFTinfo(tokenID: number): Promise<string> {
		return this.contract.FTMap(tokenID);
	}
	/** 根据tokenID查询该FT下所有购买者
	 * @param tokenID uint256
	 * @return address[]
	 */
	getBuyers(tokenID: number): Promise<Array<string>> {
		return this.contract.buyers(tokenID);
	}
	// 2. function
	/** 修改价格
	 * @param tokenID uint256
	 * @param newPrice uint256
	 */
	alertPrice(tokenID: number, newPrice: number): Promise<void> {
		const { contract } = initContract();
		return contract.alertPrice(tokenID, newPrice);
	}
	alertDescription(tokenID: number, newDes: string): Promise<void> {
		const { contract } = initContract();
		return contract.alertDescription(tokenID, newDes);
	}
	// 3. event
	E_createFT(account: TopicAccount){
		const eventFilter = this.contract.filters.CreateFT(account);
		return this.contract.queryFilter(eventFilter);
	}
	E_alertPrice(tokenID: TopicInt){
		const eventFilter = this.contract.filters.AlertPrice(tokenID);
		return this.contract.queryFilter(eventFilter);
	}
	E_alertDescription(tokenID: TopicInt){
		const eventFilter = this.contract.filters.AlertDescription(tokenID);
		return this.contract.queryFilter(eventFilter);
	}
}

export class BasePerson {
	constructor(){
		const { contract } = initContract();
		this.contract = contract;
	}
	contract;
	// 1. var
		/**
	 * 获取用户信息
	 * @param account address
	 * @return string(json)
	 */
		 getPER_items(account: string): Promise<string> {
			return this.contract.PER_items(account);
		}
		/**
		 * 获取广告等级和广告图片链接
		 * @param account address
		 * @return 1$https://www.example.com
		 */
		getPER_ad(account: string): Promise<string> {
			return this.contract.PER_ad(account);
		}
		/**
		 * 获取个人信用值
		 * @param account address
		 */
		getPER_credit(account: string): Promise<number> {
			return this.contract.PER_credit(account);
		}
		/**
		 * 获取个人拥有的FT
		 * @param account address
		 * @return [tokenID, tokenID, ...]
		 */
		getPER_ownedFT(account: string): Promise<Array<number>> {
			return this.contract.getPER_ownedFT(account);
		}
		/**
		 * 获取个人购买的FT
		 * @param account address
		 * @return [tokenID, tokenID, ...]
		 */
		getPER_boughtFT(account: string): Promise<Array<number>> {
			return this.contract.getPER_boughtFT(account);
		}
		/**
		 * 获取个人拥有的粉丝
		 * @param account address
		 * @return [address, address, ...]
		 */
		getPER_fans(account: string): Promise<Array<string>> {
			return this.contract.getPER_fans(account);
		}
		/**
		 * 获取个人拥有的粉丝
		 * @param account address
		 * @return [address, address, ...]
		 */
		getPER_follow(account: string): Promise<Array<string>> {
			return this.contract.getPER_follow(account);
		}
		// 2. function
		/**
		 * 自己修改自己的信息
		 * @param items string(json)
		 */
		alertPER_items(items: string): Promise<void> {
			return this.contract.alertPER_items(items);
		}
		/**
		 * 修改自己的广告等级和广告图片链接
		 * @param ad <广告等级>$<广告链接>
		 */
		alertPER_ad(ad: string): Promise<void> {
			return this.contract.alertPER_ad(ad);
		}
		/**
		 * 降低某位用户的信用分，每位管理员对同一位用户只能操作一次
		 * @param account address
		 */
		reducePER_credit(account: string): Promise<void> {
			return this.contract.reducePER_credit(account);
		}
		/**
		 * 撤销降低，需要之前操作过
		 * @param account address
		 */
		revokeReduce(account: string): Promise<void> {
			return this.contract.revokeReduce(account);
		}
		// 3. event
		E_alertPER_items(account: TopicAccount){
			const eventFilter = this.contract.filters.AlertPER_items(account);
			return this.contract.queryFilter(eventFilter);
		}
		E_alertPER_ad(account: TopicAccount){
			const eventFilter = this.contract.filters.AlertPER_ad(account);
			return this.contract.queryFilter(eventFilter);
		}
		E_alertCredit(admin: TopicAccount, account: TopicAccount){
			const eventFilter = this.contract.filters.AlertCredit(admin, account);
			return this.contract.queryFilter(eventFilter);
		}
}

export class BaseCopyright {
	constructor(){
		const { contract } = initContract();
		this.contract = contract;
	}
	contract;
	// 1. var
		/**
		 * 获取某消息同意的管理员人数
		 * @param tokenID uint256
		 */
		getApproveCount(tokenID: number): Promise<number> {
			return this.contract.approveCount(tokenID);
		}
		/**
		 * 获取某管理员处理的所有消息
		 * @param account address
		 * @return [tokenID, tokenID, ...]
		 */
		getProcessed(account: string): Promise<Array<number>> {
			return this.contract.getProcessed(account);
		}
		/**
		 * 获取某FT的所有举报人
		 * @param tokenID uint256
		 * @return [address, address, ...]
		 */
		getMES_reporters(tokenID: number): Promise<Array<string>> {
			return this.contract.getMES_reporters(tokenID);
		}
		/**
		 * 获取所有已经提交举报的tokenID
		 * @return [tokenID, tokenID, ...]
		 */
		getReportedTokenID(): Promise<Array<number>> {
			return this.contract.getReportedTokenID();
		}
		// 2. function
		/**
		 * 举报某件FT
		 * @param tokenID uint256
		 */
		report(tokenID: number): Promise<void> {
			return this.contract.report(tokenID);
		}
		/**
		 * 管理员同意某举报FT的消息
		 * @param tokenID uint256
		 */
		approve(tokenID: number): Promise<void> {
			const { contract } = initContract();
			return this.contract.approve(tokenID);
		}
		/**
		 * 管理员拒绝某举报FT的消息
		 * @param tokenID uint256
		 */
		reject(tokenID: number): Promise<void> {
			return this.contract.reject(tokenID);
		}
		/**
		 * 管理员忽略某举报FT的消息
		 * @param tokenID uint256
		 */
		ignore(tokenID: number): Promise<void> {
			return this.contract.ignore(tokenID);
		}
		/**
		 * 购买某件FT，调用时传入其他人地址就是为别人购买，
		 * @param tokenID uint256
		 * @param account address
		 */
		buyFT(tokenID: number, account: string): Promise<void> {
			return this.contract.buyFT(tokenID, account);
		}
		/**
		 * 铸造FT
		 * @param tokenURI 图片链接，需要ipfs
		 * @param owner address, 可以为自己和他人打造
		 * @param price uint256
		 * @param description string
		 */
		createFT(tokenURI: string, owner: string, price: number, description: string): Promise<void> {
			return this.contract.addFT(tokenURI, owner, price, description);
		}
		// 3. event
		E_alertCredit(admin: TopicAccount, account: TopicAccount){
			const eventFilter = this.contract.filters.AlertCredit(admin, account);
			return this.contract.queryFilter(eventFilter);
		}
		E_submit(){
			const eventFilter = this.contract.filters.Submit();
			return this.contract.queryFilter(eventFilter);
		}
		E_report(reporter: TopicAccount, tokenID: TopicInt){
			const eventFilter = this.contract.filters.Report(reporter, tokenID);
			return this.contract.queryFilter(eventFilter);
		}
		E_processAction(admin: TopicAccount, tokenID: TopicInt){
			const eventFilter = this.contract.filters.ProcessAction(admin, tokenID);
			return this.contract.queryFilter(eventFilter);
		}
		E_pirate(){
			const eventFilter = this.contract.filters.Pirate();
			return this.contract.queryFilter(eventFilter);
		}
		E_buyFT(sender: TopicAccount, account: TopicAccount, tokenID: TopicInt){
			const eventFilter = this.contract.filters.BuyFT(sender, account, tokenID);
			return this.contract.queryFilter(eventFilter);
		}
}

export class BaseCommunity {
	constructor(){
		const { contract } = initContract();
		this.contract = contract;
	}
	contract;
	// 2. function
	/**
	 * 关注某位博主
	 * @param account address 博主的地址
	 */
	 follow(account: string): Promise<void> {
		return this.contract.follow(account);
	}
	/**
	 * 取消关注某位博主，由于要遍历，消耗的gas可能会很多
	 * @param account address 博主的地址
	 */
	cancelFollow(account: string): Promise<void> {
		return this.contract.cancelFollow(account);
	}
	// 3. event
	E_alertFollow(sender: TopicAccount, account: TopicAccount, followOrCancel: TopicBool){
		const eventFilter = this.contract.filters.AlertFollow(sender, account, followOrCancel);
		return this.contract.queryFilter(eventFilter);
	}
}
// todo 封装基础api
export class Auth extends BaseAuth {
	
}
export class Photo extends BasePhoto{}
export class Person extends BasePerson{}
export class Copyright extends BaseCopyright{}
export class Community extends BaseCommunity{}
