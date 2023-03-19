require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'

----------------- TOW BAR -----------------------

table.insert(ProceduralDistributions["list"]["CrateMechanics"].items, "TowingCar.TowBar");
table.insert(ProceduralDistributions["list"]["CrateMechanics"].items, 2);
table.insert(ProceduralDistributions["list"]["MechanicShelfTools"].items, "TowingCar.TowBar");
table.insert(ProceduralDistributions["list"]["MechanicShelfTools"].items, 10);
table.insert(ProceduralDistributions["list"]["MechanicShelfTools"].junk.items, "TowingCar.TowBar");
table.insert(ProceduralDistributions["list"]["MechanicShelfTools"].junk.items, 75);

table.insert(SuburbsDistributions["all"]["crate"].items, "TowingCar.TowBar");
table.insert(SuburbsDistributions["all"]["crate"].items, 0.2);

table.insert(VehicleDistributions.TrunkHeavy.items, "TowingCar.TowBar");
table.insert(VehicleDistributions.TrunkHeavy.items, 10);
