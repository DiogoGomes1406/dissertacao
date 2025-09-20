function hit_value= check_compliance(I_vector, I_compliance)
%check_compliance Checks if a compliance was hit

    if any(I_vector >0.95*  I_compliance)
        hit_value=1;
    else
        hit_value=0;
    end
end

