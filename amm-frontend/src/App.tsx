import React, { useEffect, useMemo, useState } from 'react';
import {
  useConnectUI,
  useIsConnected,
  useWallet,
} from '@fuels/react';
import { AMMContractAbi__factory, AMMContractAbi } from './amm-abi';
import { BN } from 'fuels';
import AssetIdInput  from '@fuels/react'
import IdentityInput from '@fuels/react'

const App: React.FC = () => {
  const [amountA, setAmountA] = useState<string>('');
  const [amountB, setAmountB] = useState<string>('');
  const [recipient, setRecipient] = useState<string>('');
  const { isConnected } = useIsConnected();
  const { connect, isConnecting } = useConnectUI();
  const { wallet } = useWallet();

  const contractAddress =
    '0xf06f99125673ee37e2edef52cfa798daccb4603914cd1147057310d01c3b6677';

  const contract = useMemo(() => {
    if (wallet) {
      const ammContract = AMMContractAbi__factory.connect(contractAddress, wallet);
      return ammContract;
    }
  }, [wallet]);

  const addLiquidity = async () => {
    if (contract) {
      try {
        const assetIdInputA: any = { value: new BN(amountA) };
        const assetIdInputB: any = { value: new BN(amountB) };
        const reciepientInput: any = { value: recipient };
        
        const tx = await contract.functions
          .add_liquidity(assetIdInputA, assetIdInputB, reciepientInput)
          .txParams({ gasPrice: 1 })
          .call();

        console.log('Transaction:', tx);
        alert('Liquidity added (check console for transaction details)');
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
};

export default App;