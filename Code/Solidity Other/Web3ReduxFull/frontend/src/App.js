import Background from "./components/Background";
import Router from "./router/router";
import { Typography, Container } from "@material-ui/core";

function App() {
  return (
    <div>
        <Background></Background>
        <Container>
          <Typography style={{fontSize: 40, color: "cyan", "text-align": "center"}}>Contract Test Web3</Typography>
          <br></br>
          <Router></Router>
        </Container>
    </div>
  );
}

export default App;
