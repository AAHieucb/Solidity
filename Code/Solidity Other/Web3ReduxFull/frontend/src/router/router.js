import Page2 from "./SecondPage";
import {BrowserRouter, Routes, Route, Link, Navigate} from "react-router-dom";
import ConnectorContainer from "../containers/ConnectorContainer";
import auth from "./auth";

function CheckForRender({properties}){
    return (
        <div>
            {auth.isAuthenticated() ? properties.Comp : <Navigate to={properties.path}/>}
        </div>
    )
}

function Router(){
    return(
        <BrowserRouter>
            <Routes>
                <Route path="/content" element={<CheckForRender properties={{
                    path: "/",
                    Comp: <Page2/>
                }} />}/>
                <Route path="/" element={<ConnectorContainer/>}/>
            </Routes>
        </BrowserRouter>
    )
}

export default Router;