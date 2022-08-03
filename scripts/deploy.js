async function main() {
  const DigitalCard = await ethers.getContractFactory("Digitalcard");

  // Start deployment, returning a promise that resolves to a contract object
  const Digital_Card = await DigitalCard.deploy();   
  console.log("Contract deployed to address:", Digital_Card.address);
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });