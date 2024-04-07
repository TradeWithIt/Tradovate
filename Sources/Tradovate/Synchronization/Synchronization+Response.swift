import Foundation

public extension Tradovate.Synchronization {
    struct Response {
        public struct OrderStrategyResponse: Decodable {
            let errorText: String?
            let orderStrategy: OrderStrategy?
        }
        
        public struct Synchronization: Decodable {
            let users: [User]
            let accounts: [Account]?
            let accountRiskStatuses: [AccountRiskStatus]?
            let marginSnapshots: [MarginSnapshot]?
            let userAccountAutoLiqs: [UserAccountAutoLiq]?
            let cashBalances: [CashBalance]?
            let currencies: [Currency]?
            let positions: [Position]?
            let fillPairs: [FillPair]?
            let orders: [Order]?
            let contracts: [Contract]?
            let contractMaturities: [ContractMaturity]?
            let products: [Product]?
            let exchanges: [Exchange]?
            let spreadDefinitions: [SpreadDefinition]?
            let commands: [Command]?
            let commandReports: [CommandReport]?
            let executionReports: [ExecutionReport]?
            let orderVersions: [OrderVersion]?
            let fills: [Fill]?
            let orderStrategies: [OrderStrategy]?
            let orderStrategyLinks: [OrderStrategyLink]?
            let userProperties: [UserProperty]?
            let properties: [Property]?
            let userPlugins: [UserPlugin]?
            let contractGroups: [ContractGroup]
            let orderStrategyTypes: [OrderStrategyType]?
        }

        public struct User: Decodable {
            let id: Int?
            let name, timestamp, email, status: String
            let professional: Bool
            let organizationId, linkedUserId, foreignIntroducingBrokerId: Int?
        }

        public struct Account: Decodable {
            let id: Int?
            let name: String
            let userId: Int
            let accountType, active: String
            let clearingHouseId, riskCategoryId, autoLiqProfileId: Int
            let marginAccountType, legalStatus, timestamp: String
            let readonly: String?
        }

        public struct AccountRiskStatus: Decodable {
            let id: Int?
            let adminAction: String?
            let adminTimestamp, liquidateOnly: Date?
            let userTriggeredLiqOnly: Bool?
        }

        public struct MarginSnapshot: Decodable {
            let id: Int?
            let timestamp: String
            let riskTimePeriodId: Int
            let initialMargin, maintenanceMargin, autoLiqLevel, liqOnlyLevel: Double
            let totalUsedMargin, fullInitialMargin, positionMargin: Double
        }

        public struct UserAccountAutoLiq: Decodable {
            let id: Int?
            let changesLocked: Bool?
            let marginPercentageAlert, dailyLossPercentageAlert, dailyLossAlert, marginPercentageLiqOnly: Double?
            let dailyLossPercentageLiqOnly, dailyLossLiqOnly, marginPercentageAutoLiq, dailyLossPercentageAutoLiq: Double?
            let dailyLossAutoLiq, weeklyLossAutoLiq, flattenTimestamp, trailingMaxDrawdown: Double?
            let trailingMaxDrawdownLimit: Double?
            let trailingMaxDrawdownMode, dailyProfitAutoLiq, weeklyProfitAutoLiq: String?
            let doNotUnlock: Bool?
        }

        public struct CashBalance: Decodable {
            let id: Int?
            let accountId: Int
            let timestamp, currencyId: String
            let amount: Double
            let realizedPnL, weekRealizedPnL, amountSOD: Double?
            let tradeDate: TradeDate
        }

        public struct TradeDate: Decodable {
            let year, month, day: Int
        }

        public struct Currency: Decodable {
            let id: Int?
            let name: String
            let symbol: String?
        }

        public struct Position: Decodable {
            let id: Int?
            let accountId, contractId: Int
            let timestamp: String
            let tradeDate: TradeDate
            let netPos: Int
            let netPrice, boughtValue, soldValue, prevPrice: Double
            let bought, sold: Int
            let prevPos: Int?
        }

        public struct FillPair: Decodable {
            let id: Int?
            let positionId, buyFillId, sellFillId, qty: Int
            let buyPrice, sellPrice: Double
            let active: Bool
        }

        public struct Order: Decodable {
            let id: Int?
            let contractId, spreadDefinitionId: Int?
            let accountId: Int
            let timestamp, action, ordStatus: String
            let executionProviderId, ocoId, parentId, linkedId: Int?
            let admin: Bool
        }

        public struct Contract: Decodable {
            let id: Int?
            let contractMaturityId: Int
            let name: String
        }

        public struct ContractMaturity: Decodable {
            let id: Int?
            let productId, expirationMonth: Int
            let expirationDate: Date
            let firstIntentDate: Date?
            let underlyingId: Int?
            let isFront: Bool
        }

        public struct Product: Decodable {
            let id: Int?
            let currencyId, exchangeId, contractGroupId, riskDiscountContractGroupId: Int
            let name, productType, description, status: String
            let months: String?
            let isSecured: Bool?
            let valuePerPoint, tickSize: Double
            let priceFormatType: String
            let priceFormat: Int
        }

        struct Exchange: Decodable {
            let id: Int?
            let name: String
        }

        public struct SpreadDefinition: Decodable {
            let id: Int?
            let timestamp: Date
            let spreadType: String
            let uds: Bool
        }

        public struct Command: Decodable {
            let id: Int?
            let orderId: Int
            let timestamp, commandType, commandStatus: String
            let senderId, userSessionId: Int?
            let clOrdId, activationTime, customTag50: String?
            let isAutomated: Bool?
        }

        public struct CommandReport: Decodable {
            let id: Int?
            let commandId: Int
            let timestamp: Date?
            let commandStatus: String
            let rejectReason, text, ordStatus: String?
        }

        public struct ExecutionReport: Decodable {
            let id: Int?
            let commandId, accountId, contractId: Int
            let name, timestamp: String
            let tradeDate: TradeDate
            let orderId: Int
            let execType, action: String
            let execRefId, ordStatus: String?
            let cumQty: Int?
            let avgPx, lastQty, lastPx: Double?
            let rejectReason, text, exchangeOrderId: String?
        }

        public struct OrderVersion: Decodable {
            let id: Int?
            let orderId, orderQty: Int
            let orderType: String
            let price, stopPrice, maxShow, pegDifference: Double?
            let timeInForce, expireTime, text: String?
        }

        public struct Fill: Decodable {
            let id: Int?
            let orderId, contractId: Int
            let timestamp: Date
            let tradeDate: TradeDate
            let action: String
            let qty: Int
            let price: Double
            let active: Bool
            let finallyPaired: Int
        }

        public struct OrderStrategy: Decodable {
            let id: Int?
            let accountId, contractId, orderStrategyTypeId, initiatorId: Int
            let timestamp, action, status: String
            let params, uuid, failureMessage: String?
            let senderId: Int
            let customTag50: String
            let userSessionId: Int
        }

        public struct OrderStrategyLink: Decodable {
            let id: Int?
            let orderStrategyId, orderId: Int
            let label: String
        }

        public struct UserProperty: Decodable {
            let id: Int?
            let userId, propertyId: Int
            let value: String?
        }

        public struct Property: Decodable {
            let id: Int?
            let name, propertyType: String
            let enumOptions, defaultValue: String?
        }

        public struct UserPlugin: Decodable {
            let id: Int?
            let userId: Int
            let timestamp: Date
            let planPrice: Double
            let creditCardTransactionId, cashBalanceLogId, creditCardId, accountId: Int?
            let pluginName: String
            let approval: Bool
            let entitlementId: Int
            let startDate, expirationDate: TradeDate
            let paidAmount: Double
            let autorenewal: Bool?
            let planCategories: String?
        }

        public struct ContractGroup: Decodable {
            let id: Int?
            let name: String
        }

        public struct OrderStrategyType: Decodable {
            let id: Int?
            let name: String
            let enabled: Bool
        }

    }
}
