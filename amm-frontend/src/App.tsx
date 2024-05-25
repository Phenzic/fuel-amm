import { useEffect, useState } from 'react';
import {
  useConnectUI,
  useIsConnected,
  useWallet,
} from '@fuels/react';
import { AMMContractAbi__factory } from './amm-abi';
import { AMMContractAbi } from './amm-abi';

function App() {
  const [contract, setContract] = useState(null);
  const [amountA, setAmountA] = useState('');
  const [amountB, setAmountB] = useState('');
  const [recipient, setRecipient] = useState('');
  const { isConnected } = useIsConnected();
  const { wallet } = useWallet();

  const contractAddress =
    '0xf06f99125673ee37e2edef52cfa798daccb4603914cd1147057310d01c3b6677';

  useEffect(() => {
    if (isConnected && wallet) {
      const ammContract = AMMContractAbi__factory.connect(contractAddress, wallet);
      setContract(ammContract);
    }
  }, [isConnected, wallet]);

  const addLiquidity = async () => {
    if (contract) {
      try {
        const tx = await contract.functions
          .add_liquidity(amountA, amountB, recipient)
          .call();
        await tx.wait();
        alert('Liquidity added');
      } catch (error) {
        console.error('Error adding liquidity:', error);
      }
    }
  };

  
  return (
    <div className="App">
      <header className="App-header">
        <h2>Add Liquidity</h2>
        <input
          type="text"
          placeholder="Amount A"
          value={amountA}
          onChange={(e) => setAmountA(e.target.value)}
        />
        <input
          type="text"
          placeholder="Amount B"
          value={amountB}
          onChange={(e) => setAmountB(e.target.value)}
        />
        <input
          type="text"
          placeholder="Recipient Address"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
        />
        <button onClick={addLiquidity}>Add Liquidity</button>
      </header>
    </div>
  );
}

export default App;
