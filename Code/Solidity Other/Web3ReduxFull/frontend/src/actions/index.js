import {UPDATE_WEB3} from "./constants";

export const updateWeb3 = (data) => {
    return {
        type: UPDATE_WEB3,
        data: data
    }
}