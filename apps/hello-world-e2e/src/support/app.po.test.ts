import * as app_po from "./app.po"
// @ponicode
describe("app_po.getGreeting", () => {
    test("0", () => {
        let callFunction: any = () => {
            app_po.getGreeting()
        }
    
        expect(callFunction).not.toThrow()
    })
})
