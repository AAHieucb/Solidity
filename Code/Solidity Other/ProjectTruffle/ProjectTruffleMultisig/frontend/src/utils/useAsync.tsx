import { useState } from "react";

interface State<Response> {
    pending: boolean;
    error: Error | null | unknown;
    data: Response | null;
}

interface CallResponse<Response> {
    data?: Response;
    error?: Error | unknown;
}

interface UseAsync<Params, Response> extends State<Response> {
    call: (params: Params) => Promise<CallResponse<Response>>;
}

// Cơ chế: gọi useAsync(<tên hàm bất đồng bộ>); vd ta truyền vào hàm unlockAccount là người dùng kết nối với ví metamask thì req = unlockAccount, khi đó param = null, Response bằng cả cái object. 
// Khi gọi nó sẽ thực hiện đồng bộ từ trên xuống là tạo ra biến state lưu pending, error, data, khởi tạo giá trị ban đầu như dưới. Sau đó định nghĩa hàm call là hàm gọi cái hàm của async của ta như bình thường: nếu hàm thực hiện thành công thì trả ra data, nếu k hàm call sẽ trả ra error và gán giá trị pending tương ưng
// => Bên ngoài dùng: lấy call và pending. Pending để tạo loading, call để gọi hàm và bắt error hay data
function useAsync<Params, Response>(
    req: (params: Params) => Promise<Response>
): UseAsync<Params, Response> {
    const [state, setState] = useState<State<Response>>({
        pending: false,
        error: null,
        data: null,
    });

    async function call(params: Params): Promise<CallResponse<Response>> {
        setState((state) => ({
            ...state,
            pending: true,
            data: null,
            error: null,
        }));

        try {
            const data = await req(params);
            setState((state) => ({
                ...state,
                pending: false,
                data,
            }));

            return { data };
        } catch (error) {
            setState((state) => ({
                ...state,
                pending: false,
                error,
            }));

            return { error };
        }
    }

    return {
        ...state,
        call,
    };
}

export default useAsync;