import React from 'react';
import ReactDOM from 'react-dom';
import 'semantic-ui-css/semantic.min.css'
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import {
  Provider as Web3Provider,
  Updater as Web3Updater
} from "./contexts/Web3";
import {
  Provider as DataProvider,
  Updater as DataUpdater
} from "./contexts/ContractData";

ReactDOM.render(
  <React.StrictMode>
    <Web3Provider>
      <DataProvider>
        <App />
        <Web3Updater/>
        <DataUpdater/>
      </DataProvider>
    </Web3Provider>
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
