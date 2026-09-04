# Business findings

The sample run demonstrates how transactional purchasing data can be converted into operational controls.

## Main observations

1. **NordTech Components GmbH has the largest ordered value.** Its purchase orders total EUR 6,005.
2. **Seven purchase-order items remain fully or partially open.** These include partial receipts and items with no receipt.
3. **Orders 450004 and 450007 require follow-up.** Both contain quantities that have not yet been delivered completely.
4. **Orders 450008 and 450010 have no goods receipts.** They remain open in the source data.
5. **Partial deliveries are only partially invoiced in some cases.** The invoice control flags the difference for review rather than automatically calling it an error.
6. **Order 450009 has a EUR 10 invoice variance.** This deliberate exception demonstrates how an automated control highlights a case for investigation.
7. **Late receipts exist in the dataset.** This enables supplier delivery-performance analysis using requested and actual receipt dates.

## Interpretation

An amount difference does not automatically mean that an invoice is incorrect. A partial delivery may lead to a partial invoice. In production, the next control would compare invoice quantities and values at item level and account for tolerances, taxes, freight and credit notes.

## Recommended next steps

- Add item-level invoice records for a complete three-way match.
- Add purchasing organisation, plant and storage-location dimensions.
- Create a dashboard for open value, late items and supplier performance.
- Reimplement selected logic in an SAP practice environment using ABAP CDS.

