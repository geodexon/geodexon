function CreateApartment(pos)
    return {Position = pos, Available = true}
end

Apartments = {
    -- Pink Cage
    CreateApartment(vector4(313.0, -218.5, 54.22, 343.72)),
    CreateApartment(vector4(311.04, -217.84, 54.22, 332.1)),
    CreateApartment(vector4(307.41, -216.37, 54.22, 339.75)),
    CreateApartment(vector4(308.01, -213.54, 54.22, 245.77)),
    CreateApartment(vector4(310.17, -208.33, 54.22, 242.15)),
    CreateApartment(vector4(311.71, -203.69, 54.22, 240.58)),
    CreateApartment(vector4(313.67, -198.24, 54.22, 246.27)),
    CreateApartment(vector4(315.65, -195.17, 54.23, 154.64)),
    CreateApartment(vector4(319.09, -196.34, 54.23, 155.59)),
    CreateApartment(vector4(321.19, -197.45, 54.23, 158.11)),
    CreateApartment(vector4(344.54, -204.86, 54.22, 67.39)),
    CreateApartment(vector4(342.71, -209.57, 54.22, 96.4)),
    CreateApartment(vector4(340.71, -214.79, 54.22, 75.53)),
    CreateApartment(vector4(338.94, -219.33, 54.22, 55.71)),
    CreateApartment(vector4(336.59, -224.62, 54.22, 62.24)),
    CreateApartment(vector4(335.23, -226.93, 54.22, 335.88)),
    CreateApartment(vector4(331.47, -225.71, 54.22, 338.19)),
    CreateApartment(vector4(329.59, -224.71, 54.22, 337.77)),
    CreateApartment(vector4(329.57, -224.88, 58.02, 327.21)),
    CreateApartment(vector4(331.54, -225.6, 58.02, 341.54)),
    CreateApartment(vector4(335.15, -226.92, 58.02, 342.53)),
    CreateApartment(vector4(336.78, -224.6, 58.02, 68.9)),
    CreateApartment(vector4(338.82, -219.35, 58.02, 77.39)),
    CreateApartment(vector4(340.54, -214.64, 58.02, 72.27)),
    CreateApartment(vector4(342.82, -209.49, 58.02, 70.53)),
    CreateApartment(vector4(344.5, -204.91, 58.02, 60.04)),
    CreateApartment(vector4(312.97, -218.68, 58.02, 333.77)),
    CreateApartment(vector4(310.91, -217.81, 58.02, 353.18)),
    CreateApartment(vector4(307.53, -216.3, 58.02, 321.47)),
    CreateApartment(vector4(307.82, -213.4, 58.02, 247.68)),
    CreateApartment(vector4(309.75, -208.2, 58.02, 236.76)),
    CreateApartment(vector4(311.56, -203.62, 58.02, 248.69)),
    CreateApartment(vector4(313.56, -198.27, 58.02, 245.19)),
    CreateApartment(vector4(315.71, -195.07, 58.02, 158.6)),
    CreateApartment(vector4(319.33, -196.6, 58.02, 152.65)),
    CreateApartment(vector4(321.29, -197.18, 58.02, 182.6)),

}

for i=1,1024 do
    if not Apartments[i] then
        Apartments[i] = CreateApartment(vector4(313.26, -225.24, 54.22, 158.38))
    end
end