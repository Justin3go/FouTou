// 客户端能力逐步加强，我想构建一个不依赖于服务器的web3应用，提供的能力：分页查询
// 1. 依赖于ethers，暂不考虑web3.js
// 2. 应该会将之前的数据存储在内存中，依赖于pinia？算了，还是用了变量保存，然后返回数据让开发者自己去存储
// 3. 考虑是否需要封装为装饰器
// 4. 还需要调研事件是否会被清除

// 需要一个startBlock,blockStep,size,page
export class ethersQuery{

}