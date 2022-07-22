import axios from "axios";
import { ethers, EventFilter } from "ethers";
import contractABI from "../../../contracts/artifacts/FouTou.json";
// import { useEtherStore } from "@/store/etherStore"; 非vue组件不能使用pinia

const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS;

// 数组代表可选：https://docs.ethers.io/v5/concepts/events/#events--filters
type TopicAccount = string | null | Array<any>;
type TopicBool = boolean | null | Array<any>;

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
		const { contract } = initContract(); // todo 这个其实可以移动到全局去
		this.contract = contract;
	}
	contract;
	// 合约自带方法
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
	/** 获取预计管理员的数量 */
	getADMIN_NUM(): Promise<number> {
		return this.contract.ADMIN_NUM();
	}
	getREQUIRED_ADMIN(): Promise<number> {
		return this.contract.REQUIRED_ADMIN();
	}
	getREQUIRED_REPOERTER(): Promise<number> {
		return this.contract.REQUIRED_REPOERTER();
	}
	getREQUIRED_FANS(): Promise<number> {
		return this.contract.REQUIRED_FANS();
	}
	getIS_TEST_VERSION(): Promise<boolean> {
		return this.contract.IS_TEST_VERSION();
	}
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
	// 事件相关，参数名字虽然与合约事件参数名相同，但这里代表的是该参数的topic集合
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
}
// TODO 下次从这里开始
export class BasePhoto {
	/** 根据tokenID查询FT所有信息
	 * @param tokenID uint256
	 * @return json  // todo
	 */
	getFTinfo(tokenID: number): Promise<string> {
		const { contract } = initContract();
		return contract.FTMap(tokenID);
	}
	/** 根据tokenID查询该FT下所有购买者
	 * @param tokenID uint256
	 * @return address[]
	 */
	getBuyers(tokenID: number): EventFilter {
		// todo 接下来就是试试这个事件是否能查成功，还有per_owned——FT
		const { contract } = initContract();
		return contract.filters.BuyFT(null, null, tokenID);
	}
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
}

export class BasePerson {}

export class BaseCopyright {}

export class BaseCommunity {}

export const Auth_ = {
	/**
	 * 验证某个账户是否属于某个角色(SUPER_ADMIN, ADMIN, USER)
	 * @param role bytes32 哈希了的role字符，以下三选一
	 * SUPER_ADMIN=>0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
	 * ADMIN=>0xd980155b32cf66e6af51e0972d64b9d5efe0e6f237dfaa4bdc83f990dd79e9c8
	 * USER=>0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
	 * @param account address
	 */
	verifyRole(role: string, account: string): Promise<boolean> {
		const { contract } = initContract();
		return contract.roles(role, account);
	},
	getRigister(admin: string) {
		const { contract } = initContract();
		let eventFilter = contract.filters.Register(admin);
		return contract.queryFilter(eventFilter);
	},

	getADMIN_NUM(): Promise<number> {
		const { contract } = initContract();
		return contract.ADMIN_NUM();
	},
	getREQUIRED_ADMIN(): Promise<number> {
		const { contract } = initContract();
		return contract.REQUIRED_ADMIN();
	},
	getREQUIRED_REPOERTER(): Promise<number> {
		const { contract } = initContract();
		return contract.REQUIRED_REPOERTER();
	},
	getREQUIRED_FANS(): Promise<number> {
		const { contract } = initContract();
		return contract.REQUIRED_FANS();
	},
	getIS_TEST_VERSION(): Promise<boolean> {
		const { contract } = initContract();
		return contract.IS_TEST_VERSION();
	},
	// setConfig(){},
	// transferSUPER_ADMIN(){},
	/**
	 * @param account address
	 */
	USER2ADMIN(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.USER2ADMIN(account);
	},
	/**
	 * @param account address
	 */
	ADMIN2USER(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.ADMIN2USER(account);
	},
	/**
	 * @param account address
	 */
	registerByAdmin(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.registerByAdmin(account);
	},
	/**
	 * @param account address
	 */
	publicRegister(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.publicRegister(account);
	},
};
export const Photo_ = {
	/**
	 * 根据tokenID查询FT所有信息
	 * @param tokenID uint256
	 * @return json  // todo
	 */
	getFTinfo(tokenID: number): Promise<string> {
		const { contract } = initContract();
		return contract.FTMap(tokenID);
	},
	/**
	 * 根据tokenID查询该FT下所有购买者
	 * @param tokenID uint256
	 * @return address[]
	 */
	getBuyers(tokenID: number): EventFilter {
		// todo 接下来就是试试这个事件是否能查成功，还有per_owned——FT
		const { contract } = initContract();
		return contract.filters.BuyFT(null, null, tokenID);
	},
	/**
	 * 修改价格
	 * @param tokenID uint256
	 * @param newPrice uint256
	 */
	alertPrice(tokenID: number, newPrice: number): Promise<void> {
		const { contract } = initContract();
		return contract.alertPrice(tokenID, newPrice);
	},
	alertDescription(tokenID: number, newDes: string): Promise<void> {
		const { contract } = initContract();
		return contract.alertDescription(tokenID, newDes);
	},
};

export const Person_ = {
	/**
	 * 获取用户信息
	 * @param account address
	 * @return string(json)
	 */
	getPER_items(account: string): Promise<string> {
		const { contract } = initContract();
		return contract.PER_items(account);
	},
	/**
	 * 获取广告等级和广告图片链接
	 * @param account address
	 * @return 1$https://www.example.com
	 */
	getPER_ad(account: string): Promise<string> {
		const { contract } = initContract();
		return contract.PER_ad(account);
	},
	/**
	 * 获取个人信用值
	 * @param account address
	 */
	getPER_credit(account: string): Promise<number> {
		const { contract } = initContract();
		return contract.PER_credit(account);
	},
	/**
	 * 获取个人拥有的FT
	 * @param account address
	 * @return [tokenID, tokenID, ...]
	 */
	getPER_ownedFT(account: string): EventFilter {
		const { contract } = initContract();
		// return contract.getPER_ownedFT(account);
		return contract.filters.AddFT(null);
	},
	/**
	 * 获取个人购买的FT
	 * @param account address
	 * @return [tokenID, tokenID, ...]
	 */
	getPER_boughtFT(account: string): Promise<Array<number>> {
		const { contract } = initContract();
		return contract.getPER_boughtFT(account);
	},
	/**
	 * 获取个人拥有的粉丝
	 * @param account address
	 * @return [address, address, ...]
	 */
	getPER_fans(account: string): Promise<Array<string>> {
		const { contract } = initContract();
		return contract.getPER_fans(account);
	},
	/**
	 * 获取个人拥有的粉丝
	 * @param account address
	 * @return [address, address, ...]
	 */
	getPER_follow(account: string): Promise<Array<string>> {
		const { contract } = initContract();
		return contract.getPER_follow(account);
	},
	/**
	 * 自己修改自己的信息
	 * @param items string(json)
	 */
	alertPER_items(items: string): Promise<void> {
		const { contract } = initContract();
		return contract.alertPER_items(items);
	},
	/**
	 * 修改自己的广告等级和广告图片链接
	 * @param ad <广告等级>$<广告链接>
	 */
	alertPER_ad(ad: string): Promise<void> {
		const { contract } = initContract();
		return contract.alertPER_ad(ad);
	},
	/**
	 * 降低某位用户的信用分，每位管理员对同一位用户只能操作一次
	 * @param account address
	 */
	reducePER_credit(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.reducePER_credit(account);
	},
	/**
	 * 撤销降低，需要之前操作过
	 * @param account address
	 */
	revokeReduce(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.revokeReduce(account);
	},
};
// todo internal->private
export const Copyright_ = {
	/**
	 * 获取举报人数达到，举报消息提交的时间
	 * @param tokenID uint256
	 * @return 时间
	 */
	getMessageTime(tokenID: number): Promise<number> {
		const { contract } = initContract();
		return contract.messageTime(tokenID);
	},
	/**
	 * 获取某消息同意的管理员人数
	 * @param tokenID uint256
	 */
	getApproveCount(tokenID: number): Promise<number> {
		const { contract } = initContract();
		return contract.approveCount(tokenID);
	},
	/**
	 * 获取某管理员处理的所有消息
	 * @param account address
	 * @return [tokenID, tokenID, ...]
	 */
	getProcessed(account: string): Promise<Array<number>> {
		const { contract } = initContract();
		return contract.getProcessed(account);
	},
	/**
	 * 获取某FT的所有举报人
	 * @param tokenID uint256
	 * @return [address, address, ...]
	 */
	getMES_reporters(tokenID: number): Promise<Array<string>> {
		const { contract } = initContract();
		return contract.getMES_reporters(tokenID);
	},
	/**
	 * 获取所有已经提交举报的tokenID
	 * @return [tokenID, tokenID, ...]
	 */
	getReportedTokenID(): Promise<Array<number>> {
		const { contract } = initContract();
		return contract.getReportedTokenID();
	},
	/**
	 * 举报某件FT
	 * @param tokenID uint256
	 */
	report(tokenID: number): Promise<void> {
		const { contract } = initContract();
		return contract.report(tokenID);
	},
	/**
	 * 管理员同意某举报FT的消息
	 * @param tokenID uint256
	 */
	approve(tokenID: number): Promise<void> {
		const { contract } = initContract();
		return contract.approve(tokenID);
	},
	/**
	 * 管理员拒绝某举报FT的消息
	 * @param tokenID uint256
	 */
	reject(tokenID: number): Promise<void> {
		const { contract } = initContract();
		return contract.reject(tokenID);
	},
	/**
	 * 管理员忽略某举报FT的消息
	 * @param tokenID uint256
	 */
	ignore(tokenID: number): Promise<void> {
		const { contract } = initContract();
		return contract.ignore(tokenID);
	},
	/**
	 * 购买某件FT，调用时传入其他人地址就是为别人购买，
	 * @param tokenID uint256
	 * @param account address
	 */
	buyFT(tokenID: number, account: string): Promise<void> {
		const { contract } = initContract();
		return contract.buyFT(tokenID, account);
	},
	/**
	 * 铸造FT
	 * @param tokenURI 图片链接，需要ipfs
	 * @param owner address, 可以为自己和他人打造
	 * @param price uint256
	 * @param description string
	 */
	addFT(tokenURI: string, owner: string, price: number, description: string): Promise<void> {
		const { contract } = initContract();
		return contract.addFT(tokenURI, owner, price, description);
	},
};

export const Community_ = {
	/**
	 * 关注某位博主
	 * @param account address 博主的地址
	 */
	follow(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.follow(account);
	},
	/**
	 * 取消关注某位博主，由于要遍历，消耗的gas可能会很多
	 * @param account address 博主的地址
	 */
	cancelFollow(account: string): Promise<void> {
		const { contract } = initContract();
		return contract.cancelFollow(account);
	},
};
// todo 查出自己关注人的动态，分页展示
export const Event_ = {
	/**
	 * 分页查询自己关注的所有博主的动态
	 * @param account address
	 * @param page 第几页
	 * @param size 每页数量
	 * @return [tokenID, tokenID, ...]
	 */
	getAll(account: string, page: number, size: number): Promise<Array<number>> {
		return Promise.resolve([1]); // todo
	},
	/**
	 * 订阅自己关注的博主之后发布的图片，博主每次发布图片，就将其信息存储到本地(后续可以加一个清除本地缓存的功能)
	 */
	subscribe(account: string) {
		const { contract } = initContract();
	},
	unSubscribe(account: string) {},
};
